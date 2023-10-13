package flixel.addons.ui;

import flash.utils.Endian;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.FlxG;

/**
 * The FlxUIBitmapSize class implements utilities for tightly packing a tuple of two 16-bit integers,
 * representing a bitmap's width and height, without necessarily loading it.
 * It's using an integer to store its data to avoid allocating short-lived garbage on the heap.
 */
abstract FlxUIBitmapSize(UInt) from UInt to UInt
{
	public static inline var ZERO:FlxUIBitmapSize = 0;

	public var isZero(get, never):Bool;
	public var width(get, never):Int;
	public var height(get, never):Int;

	public inline function new(width:Int, height:Int) {
		this = cast(width, UInt) | (cast(height, UInt) << 16);
	}

	public inline function get_isZero()
	{
		return this == 0;
	}

	public inline function get_width()
	{
		return cast((this) & 0xFFFF, Int);
	}

	public inline function get_height()
	{
		return cast((this >> 16) & 0xFFFF, Int);
	}

	public static inline function fromBitmap(src:BitmapData):FlxUIBitmapSize
	{
		return new FlxUIBitmapSize(src.width, src.height);
	}

	public static inline function fromCache(src:String):FlxUIBitmapSize
	{
		if (FlxG.bitmap.checkCache(src))
		{
			return fromBitmap(FlxG.bitmap.get(src).bitmap);
		}

		return fromAsset(src);
	}

	public static inline function fromCacheWithFallback(src:String, fallback:FlxUIBitmapSize):FlxUIBitmapSize
	{
		if (FlxG.bitmap.checkCache(src))
		{
			return fromBitmap(FlxG.bitmap.get(src).bitmap);
		}

		return fallback;
	}

	public static function fromAsset(src:String):FlxUIBitmapSize
	{
		if (!Assets.exists(src))
		{
			return ZERO;
		}

		if (StringTools.endsWith(src, ".png"))
		{
			return fromAssetPng(src);
		}

		if (StringTools.endsWith(src, ".jpg") || StringTools.endsWith(src, ".jpeg"))
		{
			return fromAssetJpg(src);
		}

		if (StringTools.endsWith(src, ".bmp"))
		{
			return fromAssetBmp(src);
		}

		return fromAssetSlow(src);
	}

	private static function fromAssetSlow(src:String):FlxUIBitmapSize
	{
		trace("FlxUIBitmapSize.fromAsset encountered unknown file extension, falling back to slow load: " + src);

		var bmp = Assets.getBitmapData(src, false);
		var size = fromBitmap(bmp);
		bmp.dispose();

		return size;
	}

	private static function fromAssetPng(src:String):FlxUIBitmapSize
	{
		// PNG requires information to be stored in the IHDR chunk.
		// There's some mild flexibility in how the chunks can be laid out,
		// thus fall back to slow loading when encountering a weird .png
		var data = Assets.getBytes(src);
		data.endian = Endian.BIG_ENDIAN;

		var magic1 = data.readUnsignedInt();
		var magic2 = data.readUnsignedInt();
		if (magic1 != 0x89504E47 && magic2 != 0x0D0A1A0A)
		{
			trace("FlxUIBitmapSize.fromAssetPng expected magic 0x89504E47 0x0D0A1A0A, got: 0x" + StringTools.hex(magic1, 8) + " 0x" + StringTools.hex(magic2, 8));
			return fromAssetSlow(src);
		}

		var length = data.readUnsignedInt();
		if (length != 0x0000000D)
		{
			trace("FlxUIBitmapSize.fromAssetPng expected first chunk length 0x0000000D, got: 0x" + StringTools.hex(length, 8));
			return fromAssetSlow(src);
		}

		var marker = data.readUnsignedInt();
		if (marker != 0x49484452)
		{
			trace("FlxUIBitmapSize.fromAssetPng expected IHDR marker 0x49484452, got: 0x" + StringTools.hex(length, 8));
			return fromAssetSlow(src);
		}

		var width = data.readInt();
		var height = data.readInt();
		return new FlxUIBitmapSize(width, height);
	}

	private static function fromAssetJpg(src:String):FlxUIBitmapSize
	{
		// JPEG requires going through all chunks in the file and looking for chunks with width / height info.
		var data = Assets.getBytes(src);
		data.endian = Endian.BIG_ENDIAN;

		var magic = data.readUnsignedShort();
		if (magic != 0xFFD8)
		{
			trace("FlxUIBitmapSize.fromAssetJpg expected magic 0xFFD8, got: 0x" + StringTools.hex(magic, 4));
			return fromAssetSlow(src);
		}

		// Each chunk starts with FF ty(pe) si ze
		// Chunk size starts after the FF XX marker - the length is part of the data.

		// Need at least 9 bytes (type, length, bpp, height, width).
		while (data.bytesAvailable > 9)
		{
			var chunkType = data.readUnsignedShort();
			var chunkStart = data.position;
			var chunkLength = data.readUnsignedShort();

			if ((chunkType & 0xFFF0) == 0xFFC0) {
				// SOFn - SOF0 is default, anything higher than that is for different DCT formats.
				data.position += 1; // Skip bits per pixel.
				// JPEG / JFIF stores height first.
				var height = data.readShort();
				var width = data.readShort();
				return new FlxUIBitmapSize(width, height);
			}

			data.position = chunkStart + chunkLength;
		}

		trace("FlxUIBitmapSize.fromAssetJpg didn't find chunk 0xFFC0");
		return fromAssetSlow(src);
	}

	private static function fromAssetBmp(src:String):FlxUIBitmapSize
	{
		// BMP files always come with a mandatory file header + DIB (or BITMAPV5) header.
		var data = Assets.getBytes(src);
		data.endian = Endian.LITTLE_ENDIAN;

		var magic = data.readUnsignedShort();
		if (magic != 0x4D42)
		{
			trace("FlxUIBitmapSize.fromAssetBmp expected magic 0x4D42, got: 0x" + StringTools.hex(magic, 4));
			return fromAssetSlow(src);
		}

		// Skip right to the right position in the DIB header.
		data.position = 0x12;
		var width = data.readInt();
		var height = data.readInt();
		return new FlxUIBitmapSize(width, height);
	}
}
