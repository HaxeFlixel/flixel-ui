![](https://github.com/HaxeFlixel/haxeflixel.com/blob/dev/content/_static/images/flixel-logos/flixel-ui.png?raw=true)

[flixel](https://github.com/HaxeFlixel/flixel) | [eklentiler](https://github.com/HaxeFlixel/flixel-addons) | [ui](https://github.com/HaxeFlixel/flixel-ui) | [demolar](https://github.com/HaxeFlixel/flixel-demos) | [tools](https://github.com/HaxeFlixel/flixel-tools) | [templates](https://github.com/HaxeFlixel/flixel-templates) | [docs](https://github.com/HaxeFlixel/flixel-docs) | [haxeflixel.com](https://github.com/HaxeFlixel/haxeflixel.com)

[![CI](https://img.shields.io/github/actions/workflow/status/HaxeFlixel/flixel-ui/main.yml?branch=dev&logo=github)](https://github.com/HaxeFlixel/flixel-ui/actions?query=workflow%3ACI)
[![Discord](https://img.shields.io/discord/162395145352904705.svg?logo=discord)](https://discordapp.com/invite/rqEBAgF)
[![Haxelib Sürümü](https://badgen.net/haxelib/v/flixel-ui)](https://lib.haxe.org/p/flixel-ui)
[![Haxelib İndirmeleri](https://badgen.net/haxelib/d/flixel-ui?color=blue)](https://lib.haxe.org/p/flixel-ui)
[![Haxelib Lisansı](https://badgen.net/haxelib/license/flixel-ui)](LICENSE.md)
[![Patreon](https://img.shields.io/badge/donate-patreon-blue.svg)](https://www.patreon.com/haxeflixel)

----
# Artık Kullanılmıyor
Flixel-UI için artık özellik geliştirilmeyecek, bakımsa en azda tutulacak. Flixel oyun ve uygulamalarınızın UI ihtiyaçları için [haxeui-flixel](https://github.com/haxeui/haxeui-flixel)'ı kullanmanızı öneriyoruz.

# Hakkında

[HaxeFlixel](https://github.com/HaxeFlixel/flixel)'de UI bileşenlerini oluşturmaya ve UI etkinliklerini yönetmeye yarayan bir dizi araç. 

# Başlarken

## flixel-ui'ı kur:
haxelib'den en son kararlı sürümünü indirin:

    haxelib install flixel-ui

haxelib'den en son bıçak-kenarı geliştirici sürümünü indirin:

    haxelib install flixel-ui

## Demo Projesi!
 [flixel-demos](http://github.com/HaxeFlixel/flixel-demos) adresinde bir [test projesi](https://haxeflixel.com/demos/RPGInterface/) mevcuttur. Bu projeyi mutlaka inceleyin. XML dosyalarında çok sayıda satır içi dokümantasyon bulunmakta ve bazı karmaşık ve ince özellikler sergilenmektedir.

flixel-demos'daki test projesinin **[fireTongue](https://github.com/larsiusprime/firetongue)** yerelleştirme kütüphanesini gerektirdiğini lütfen unutmayın. Bu kütüphane şu şekilde yüklenebilir:

    haxelib install firetongue

Veya github'dan en son geliştirme sürümü için:

    haxelib git firetongue https://github.com/larsiusprime/firetongue

## Hızlı proje kurulumu
1. openfl varlıklar klasörünüzde bir "xml" yolu oluşturun
2. Her bir durum için bir xml görünüm dosyası oluşturun
3. UI odaklı durumlarınıza flixel.addons.ui.FlxUIState'i genişlettirin.
4. create()'in içinde: 

````
_xml_id = "state_battle"; //looks for "state_battle.xml"
````
kısmını ayarlayın.
XML görünümünü doğru ayarladıysanız, flixel-ui o xml dosyasını alacak ve bir _ui:FlxUI üye değişkenini otomatik olarak üretecek.
FlxUI, temel olarak devasa, kalite FLXGroup'tır, o yüzden bu yöntemi kullanmak size bir UI kapsayıcısı ve içindeki tüm UI wigetlerini ayarlayacaktır.

## El ile widget oluşturma

XML kurulumu kullanmak yerine doğrudan Haxe kodu ile FlxUI widgetları oluşturabilirsiniz.

Çalışırken görmek için, [demo projeye](https://github.com/HaxeFlixel/flixel-demos/tree/master/UserInterface/RPGInterface), özellikle [State_CodeTest](https://github.com/HaxeFlixel/flixel-demos/blob/master/UserInterface/RPGInterface/source/State_CodeTest.hx)'e bakın (derlenmiş demoda çalışırken görmek için "Code Test"e tıklayın.)

Bunu, görsel olarak aynı UI çıktısını veren ancak o sonuçları başarmak için [bu xml görünümünü](https://github.com/HaxeFlixel/flixel-demos/blob/master/UserInterface/RPGInterface/assets/xml/state_default.xml) kullanan [State_DefaultTest](https://github.com/HaxeFlixel/flixel-demos/blob/master/UserInterface/RPGInterface/source/State_DefaultTest.hx) ile karşılaştırabilirsiniz.

## Widgetlar için görsel varlıklar
### Öntanımlı Varlıklar 

Flixel-UI, temel giydirme için varsayılan bir varlık seti ([FlxUIAssets](https://github.com/HaxeFlixel/flixel-ui/blob/master/flixel/addons/ui/FlxUIAssets.hx)'e ve [varlıklar klasörü](https://github.com/HaxeFlixel/flixel-ui/tree/master/assets)'ne bakın) bulundurur. Eksik veri ve/ya tanımlamalar verirseniz, FlxUI otomatikmen varsayılan varlıklara dönmeyi deneyecektir.

### Özel Varlıklar

Kendi varlıklarınızı sunmak isterseniz, [demo projesinde](https://github.com/HaxeFlixel/flixel-demos/tree/master/UserInterface/RPGInterface) gördüğünüz aynı yapıyı kullanarak, kendi projenizin "varlıklar" klasörüne koymanız gerekmektedir.

----

# FlxUI public fonksiyonları

Genelde FlxUI sınıfında en çok kullanılan public fonksiyonları:

```haxe
//Initiate from XML Fast object:
//(This is handled automatically in the recommended setup)
load(data:Fast):Void

//Get some widget:
getAsset(key:String,recursive:Bool=true):FlxBasic

//Get some group:
getGroup(key:String,recursive:Bool=true):FlxUIGroup

//Get a text object:
getFlxText(key:String,recursive:Bool=true):FlxText

//Get a mode definition (xml list of things to show/hide):
getMode(Key:String,recursive:Bool=true):Fast

//Get a widget definition:
getDefinition(key:String,recursive:Bool=true):Fast
```
`recursive`in yukarı özyinelemeye referans verdiğini, görünümlere doğru delmeye referans vermediği unutmayın. Eğer bir görünüm etiketi kullanırsanız, `cast getAsset("mylayoutname")`ı ve sonra `getAsset()`i aşağı özyineleme gerçekleştirmek için çağırmalısınız. 

Daha az kullanılan public fonksiyonları:

```haxe
//These implement the IEventGetter interface for lightweight events
getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
getRequest(name:String, sender:Dynamic, data:Dynamic):Dynamic
//Both are empty - to be defined by the user in extended classes

//Get, Remove, and Replace assets:
removeAsset(key:String,destroy:Bool=true):FlxBasic
replaceAsset(key:String,replace:FlxBasic,center_x:Bool=true,center_y:Bool=true,destroy_old:Bool=true):FlxBasic

//Set a mode for the UI:
//  mode_id is the mode you want
//  target_id is the FlxUI object to target -
//            "" for this FlxUI, something else for a child
setMode(mode_id:String,target_id:String=""):Void
```

----

# XML görünüm temelleri
flixel-ui'daki herşey xml görünüm dosyaları ile hallonulur. İşte çok basit bir örnek:

```xml
<?xml version="1.0" encoding="utf-8" ?>
<data>	
	<sprite src="ui/title_back" x="0" y="0"/>
</data>
```

Bu, tek çocuğu tek bir sprite olan bir FlxUI nesnesi yaratacaktır. “src” parametresi görüntünün yolunu belirtir - FlxUI bunu OpenFL aracılığıyla nesneyi dahili olarak yüklemek için kullanacaktır:


```haxe
Assets.getBitmapData("assets/gfx/ui/title_back.png")
```

Gördüğünüz gibi, tüm görüntü kaynağı girişleri iki şeyi varsaymaktadır:
* Format PNG'dir (daha sonra JPG/GIF/etc desteği eklenebilir)
* Belirtilen dizin “assets/gfx/” içindedir
  * Farklı bir dizin istiyorsanız, başına aşağıdaki gibi “RAW:” ekleyin:
  * ````"RAW:path/to/my/assets/image"```` will resolve as ````"path/to/my/assets/image.png"```` instead of ```"assets/gfx/path/to/my/assets/image.png"```
    
## Etiket türleri
Bir Flixel-UI görünüm dosyasında birkaç basit xml etiket tipleri vardır.

**Widget**, ```<definition>```, ```<include>```, ```<group>```, ```<align>```, ```<position>```, ```<layout>```, ```<failure>```, ```<mode>```, and ```<change>```.

Hepsinin üzerinden tek tek geçelim.

--

### 1. Widget
Bu, ```<sprite>```, ```<button>``` , ```<checkbox>```, vb. gibi birçok Flixel-UI widget'ından herhangi biridir. Aşağıda her biri hakkında daha fazla ayrıntıya gireceğiz, ancak tüm widget etiketlerinin birkaç ortak noktası vardır:

*Özellikler:*
* **name** - dize, isteğe bağlı, benzersiz olmalıdır. Düzen boyunca bu widget'a referans vermenizi sağlar ve ayrıca FlxUI'nin ``getAsset(“some_id”)`` fonksiyonu ile isme göre getirmenizi sağlar.
* **x** ve **y** - tamsayı, konumu belirtir. Alt düğüm olarak herhangi bir bağlantı etiketi yoksa, konum mutlaktır. Bir bağlantı etiketi varsa, konum bağlantıya görelidir.*
* **use_def** - dize, isteğe bağlı, bu widget için kullanılacak ``<definition>`` etiketine adıyla başvurur.
**group** - dize, isteğe bağlı, bir ``<group>`` etiketine adıyla referans verir. Bu widget'ı FlxUI'nin kendisi yerine o grubun çocuğu yapar.
* **visible** - boolean, isteğe bağlı, düzen yüklendiğinde widget'ın görünürlüğünü ayarlar
* **aktif** - boolean, isteğe bağlı, bir widget'ın herhangi bir güncellemeye yanıt verip vermediğini kontrol eder
* **round** - x/y (ve/veya büyük boyutlu bir nesne için genişlik/yükseklik) formüllerden/çubuklardan hesaplanıyorsa, yuvarlamanın nasıl çalışacağını belirtir. Yasal değerler şunlardır:
  * **down**: aşağı yuvarla
  * **up**: yukarı yuvarla
  **round** veya **true**: ondalık >= 0,5 ise yukarı yuvarla, aksi takdirde aşağı yuvarla.
  * **false** (veya öznitelik yok): yuvarlama 
  
--

*Child nodes:*
* **\<anchor>** -  isteğe bağlı, bu widgeti diğer objenin pozisyonuna bağlı olarak yerleştirmenize izin verir.*
* **\<param>** - isteğe bağlı, parametreleri özelleştirmenize izin verir**
* **\<tooltip>** - isteğe bağlı, tooltip'i özelleştirmenize izin verir.***
* **size tags** - isteğe bağlı, bir formüle dayanarak bir widgeti dinamik olarak boyutlandırmanıza izin verir.*
* **\<locale name=“xx-YY”>** - isteğe bağlı, [fireTongue](https://github.com/larsiusprime/firetongue) entegrasyonu için bir yerel ("en-US" veya "tr-TR" gibi) ayarlamanıza olanak sağlar. Bu, yerel saatinize bağlı olarak değişiklikler yapmanıza olanak sağlar:
Örneğin:

```xml
<button center_x=“true” x=“0” y=“505” name=“battle” use_def=“text_button” group=“top” label=“$TITLE_BATTLES”>
	<param type=“string” value=“battle”/>
	<locale name=“nb-NO”>
		<change width=“96”/>
		<!--if norwegian, do 96 pixels wide instead of the default-->
	</locale>			
</button>
```

\* Anchor ve Size etiketleri hakkında daha fazla bilgi “Dinamik Konum ve Boyut” bölümünde aşağıya doğru görünür. 

\*\* Parametreler hakkında daha fazla bilgi “Pencere Araçları Listesi ”ndeki Düğme girişi altında bulunabilir. Yalnızca bazı pencere öğeleri parametre kullanır. 

\*\*\* Araç İpuçları hakkında daha fazla bilgi “Araç İpuçları” bölümünde aşağıya doğru görünür.

--

### 2. ```<definition>```

Bu, çok sayıda yeniden kullanılabilir ayrıntıyı benzersiz bir ada sahip ayrı bir etikete yüklemenize ve ardından use_def=“definition_id” niteliğini kullanarak bunları başka bir etikete çağırmanıza olanak tanır. Tanım etiketi, etiket adının “tanım” olması dışında normal bir widget etiketi gibidir.

Widget etiketinde ayrıntılar sağlarsanız ve aynı zamanda bir tanım kullanırsanız, çakıştıkları her yerde tanımdaki bilgileri geçersiz kılacaktır. Daha fazla ayrıntı için RPG Arayüzü demosuna bakın.

**Örnek:**

Çok yaygın bir kullanım, metin widget'ları için yazı tipi tanımlarıdır. Bunu yazmak yerine:
```xml
<text name="text1" x="50" y="50" text="Text 1" font="verdana" size="10" style="bold" color="0xffffff" outline="0x000000"/>
<text name="text2" x="50" y="50" text="Text 2" font="verdana" size="10" style="bold" color="0xffffff" outline="0x000000"/>
```

Bunu yapabilirsiniz:

```xml
<definition name="sans10" font="verdana" size="10" style="bold" color="0xffffff" outline="0x000000"/>
<text name="text1" use_def="sans10" x="50" y="50" text="Text 1"/>
<text name="text2" use_def="sans10" x="50" y="50" text="Text 2"/>
```

Bu durumda, her zaman kalın, beyaz ve siyah anahatlı bir metin tanımı oluşturduğumuza dikkat edin. Diyelim ki bunun yerine italik bir metin istiyoruz, ancak yeni bir tanım oluşturmak istemiyoruz:
```xml
<text name="italic_text" use_def="sans10" style="italic" x="50" y="50" text="My Italic Text"/>
```

Yazmak ile aynı şeydir

```xml
<text name="italic_text" x="50" y="50" text="My Italic Text" font="verdana" size="10" style="italic" color="0xffffff" outline="0x000000"/>
```

“sans10“ tanımındaki tüm değerler devralınır ve ardından ‘italic_text’ etiketinin tüm yerel ayarları uygulanır ve style=”bold“ yerine style=”italic” kullanılır.

### 3. ```<default>```
Varsayılan etiket, birkaç istisna dışında tıpkı bir tanım gibidir:

1. Her widget türü için yalnızca bir tane olabilir
2. “name” özelliği, bu varsayılan tanımın ait olduğu widget'ın adı olmalıdır
3. Bu tanımları “use_def” etiketleri ile kullanmazsınız

Bir widget her yüklendiğinde, o widget türü için ayarlanmış varsayılan bir tanım olup olmadığını kontrol eder. Eğer varsa, varsayılan tanımdaki tüm özellikleri otomatik olarak uygulayacaktır. Bu, “use_def ”ten kullanıcı tarafından sağlanan bir tanım etiketinin herhangi bir özelliğinin ayarlanmasından ÖNCE ve sonuçta EK olarak yapılır.

Varsayılan etiketlere ``FlxUI.getDefinition`` fonksiyonu aracılığıyla diğer etiketler gibi erişilebilir, bunlar “default:X” anahtarı altında saklanır, burada X tanımladıkları widget'ın adıdır. Yani “default:text” veya “default:button” vb.

Bunun gibi bir varsayılan tanımlarsınız:

```xml
<default name=“text” color=“red”/>
```

Bu da yerel ayarlar veya bir use_def bunu geçersiz kılmadığı sürece tüm ```<text>`` nesnelerinizi kırmızı yapacaktır.

### 4. ```<include>```
Include etiketleri, başka bir xml dosyasında saklanan tanımlara referans vermenizi sağlar. Bu, dosya şişkinliğini azaltmak ve organizasyona yardımcı olmak için kolaylık sağlayan bir özelliktir:

Bu çağırma “some_other_file.xml” dosyasında bulunan tüm tanımları içerecektir:

```xml
<include name="some_other_file"/>
```

*Yalnızca* tanım ve varsayılan etiketler dahil edilecektir. Ayrıca projenize biraz kapsam ekler - dahil edilen bir tanımın yerel olarak tanımlanmış bir tanımla aynı ada sahip olması durumunda, yerel tanım kullanılacaktır. Yalnızca FlxUI'nin tanımınızı yerel olarak bulamaması durumunda, dahil edilenleri kontrol edecektir. 

Bu özyineleme sadece bir seviye derinliktedir. Eğer dahil dosyanıza \<include> etiketleri koyarsanız, bunlar göz ardı edilecektir. 
### 5. ```<inject>```
Inject etiketleri ```<include>`` etiketlerinden daha doğrudan bir çözümdür. Diğer xml dosyasının adını ``<include>`` etiketinde olduğu gibi belirtirsiniz, ancak yalnızca tanımları dahil etmek yerine, ``<inject>`` etiketini diğer dosyanın içeriğiyle tam anlamıyla değiştirir, tabii ki ``<?xml>`` ve ``<data>`` sarmalayıcı etiketleri hariç. Bu adım herhangi bir işlem yapılmadan önce gerçekleşir.

Bu çağırma “some_other_file.xml” içinde bulunan tüm içeriği enjekte edecektir:
```xml
<inject name="some_other_file"/>
```

### 6. ```<group>```
Widget'ları atayabileceğiniz bir FlxGroup (özellikle bir FlxUIGroup) oluşturur. Widget etiketlerini \<group\> etiketinin alt xml düğümleri haline getirerek değil, widget etiketindeki “group” niteliğini grubun adına ayarlayarak bir gruba bir şeyler eklediğinizi unutmayın.

Gruplar, onları tanımladığınız sıraya göre yığılır; dosyanın en üstünde olanlar önce oluşturulur ve böylece daha sonra gelenlerin “altında” yığılır. 

Bir grup etiketi tek bir özellik alır - isim. Gruplarınızı istediğiniz sırada bir yerde tanımlayın, ardından grup niteliğini istediğiniz kimliklere ayarlayarak bunlara widget ekleyin.

### 7. ```<align>```
Nesneleri dinamik olarak hizalar, ortalar ve/veya birbirlerine göre boşluk bırakır. 
Bu, aşağıda kendi bölümünü hak edecek kadar karmaşıktır, belgenin ilerleyen bölümlerinde “Dinamik Konum ve Boyut” altındaki “Hizalama Etiketleri ”ne bakın.

### 8. ```<position>```
Bu, mevcut bir varlığı daha sonra belgede yeniden konumlandırmanıza olanak tanır. Bu, karmaşık göreli konumlandırma ve diğer kullanımlar için yararlıdır ve aşağıda kendi bölümünü hak edecek kadar karmaşıktır, belgenin ilerleyen bölümlerinde “Dinamik Konum ve Boyut” altındaki “Konum Etiketleri ”ne bakın.

### 9. ```<layout>```
Ana FlxUI içinde bir alt FlxUI nesnesi oluşturur ve içindeki tüm widget'ları ona alt nesne olarak ekler. Bu, örneğin farklı cihazlar ve ekran boyutları için birden fazla düzen oluşturmak istediğinizde özellikle kullanışlıdır. Hata etiketleriyle birleştirildiğinde, ekran boyutuna bağlı olarak en iyi düzeni otomatik olarak hesaplamanıza olanak tanır.

Bir düzenin yalnızca bir özniteliği, adı ve alt düğümleri vardır. <layout> öğesini xml dosyanızın kendi alt bölümü olarak düşünün. Tam teşekküllü bir FlxUI olduğu için, normal dosyaya koyabileceğiniz her şeyin kendi sürümlerine sahip olabilir - yani tanımlar, gruplar, widget'lar, modlar, muhtemelen diğer düzen etiketleri bile (bu test edilmemiştir).

Bir düzen içinde, kimliklere başvururken kapsamın devreye girdiğini unutmayın. Tanımlar ve nesne başvuruları önce düzenin kapsamına (yani FlxUI nesnesine) bakar ve hiçbir şey bulamazsa, üst FlxUI'da bulmaya çalışır.

### 10. ```<failure>```
Belirli bir düzen için “başarısızlık” koşullarını belirtir, böylece FlxUI, birinin diğerinden daha iyi çalışması durumunda birden fazla düzenden hangisinin seçileceğini belirleyebilir. Örneğin, değişken çözünürlüklü PC'leri ve mobil cihazları aynı anda hedeflemek için kullanışlıdır.

İşte bir örnek:
```xml
<failure target ="wave_bar" property="height" compare=">" value="15%"/>		
```

“wave_bar.height toplam flixel tuval yüksekliğinin %15'inden büyükse başarısız olur.”

Nitelikler için yasal değerler:

* değer - bir yüzde (toplam genişlik/yüksekliğin %'sini çıkarma) veya mutlak bir sayı ile sınırlandırılmıştır. 
* özelliği - ``“genişlik”`` ve ``“yükseklik”``
* karşılaştırma - ```<```,```>```,```<=```,```>=```,```=```,```==``` (```=``` ve ```==``` bu bağlamda eş anlamlıdır)

FlxUI'niz yüklendikten sonra, getAsset() kullanarak tek tek düzenlerinizi getirebilir ve ardından size başarısızlık kontrollerinin sonucunu veren bu genel özellikleri kontrol edebilirsiniz:

* **failed:Bool** - bu FlxUI belirtilen kurallara göre “başarısız” mı oldu?
* **failed_by:Float** - eğer öyleyse, ne kadar?
  
Bazen birden fazla düzen kurallarınıza göre “başarısız” olur ve en az başarısız olanı seçmek istersiniz. Başarısızlık koşulu “some_thing'in genişliği 100 pikselden büyük” ise, some_thing.width = 176 ise, failed_by 76 olur.

Başarısızlık koşullarına *yanıt* vermek için kendi kodunuzu yazmanız gerekir. RPG Arayüzü demosunda, biri 4:3 çözünürlükler için daha uygun olan ve diğeri 16:9'da daha iyi çalışan iki savaş düzeni vardır. Bu durum için özel FlxUIState, yükleme sırasında hata koşullarını kontrol edecek ve hangi düzenin en iyi çalıştığına bağlı olarak modu ayarlayacaktır. Modlardan bahsetmişken...

### 11. ```<mode>```
Aralarında geçiş yapabileceğiniz kullanıcı arayüzü “modlarını” belirtir. Örneğin, Defender's Quest'te kayıt yuvalarımız için dört durumumuz vardı - boş, play, new_game+ (Yeni Oyun+ uygun) ve play+ (Yeni Oyun+ başladı). Bu, hangi düğmelerin görünür olduğunu belirlerdi (“Yeni Oyun”, “Oyna”, “Oyna+”, “İçe Aktar”, “Dışa Aktar”).

“empty” ve ‘play’ modları şu şekilde görünebilir:

```xml
<mode name="empty">
	<show name="new_game"/>
	<show name="import"/>
			
	<hide name="space_icon"/>
	<hide name="play_big"/>
	<hide name="play_small"/>
	<hide name="play+"/>
	<hide name="export"/>
	<hide name="delete"/>
	<hide name="name"/>
	<hide name="time"/>
	<hide name="date"/>
	<hide name="icon"/>
	<hide name="new_game+"/>
</mode>
		
<mode name="play">
	<show name="play_big"/>
	<show name="export"/>
	<show name="delete"/>
	<show name="name"/>
	<show name="time"/>
	<show name="date"/>
	<show name="icon"/>			
			
	<hide name="play_small"/>
	<hide name="play+"/>
	<hide name="import"/>
	<hide name="new_game"/>
	<hide name="new_game+"/>
</mode>
```

Bir **\<mode>** öğesinde çeşitli etiketler mevcuttur. En temel olanları ```<hide>`` ve ```<show>`` etiketleridir ve her biri yalnızca name özelliğini alır. Bunlar sadece “name” niteliğiyle eşleşen widget için “visible” özelliğini açar ve kapatır. Tam liste şu şekildedir:

* **show** -- öğeyi görünür hale getirir
* **hide** -- öğeyi görünmez yapar
* **align** -- bir pencere öğesi listesinin yerleşimini hizalamanızı sağlar, belgenin ilerleyen bölümlerinde “Hizalama Etiketleri” başlığına bakın.
* **change** -- bir pencere aracının özelliğini değiştirmenizi sağlar, belgenin ilerleyen bölümlerinde “Etiketleri Değiştir” başlığına bakın.
* **position** -- bir pencere öğesini yeniden konumlandırmanızı sağlar, belgenin ilerleyen bölümlerinde “Konum Etiketleri ”ne bakın.
### 12. ```<change>```

Değiştir etiketi, bir widget oluşturulduktan sonra çeşitli özelliklerini değiştirmenize olanak tanır. “name” niteliğiyle eşleşen widget hedeflenecektir. Aşağıdaki nitelikler kullanılabilir:

* **text** -- Widget'ın ```text``` özelliğini değiştirin (FlxUIText veya FlxUIInputText). Metin ve/veya etiket içeren nesneler için “bağlam” ve “kod” niteliklerini de ayarlayabilir. \*
* **label** -- Widget'ın ``label`` özelliğini değiştirin (Düğmeler veya metin etiketi olan başka herhangi bir şey için). Ayrıca “context” ve “code” niteliklerini de ayarlayabilir.
* **width** -- Genişliği değiştirin, orijinal widget etiketinde kullandığınızla aynıdır
* **height** -- Yüksekliği değiştirin, orijinal widget etiketinde kullandığınızla aynıdır
* **<params>** (alt düğüm) -- ``params`` özelliğini bu liste olarak değiştirin.\*\*

\* “Bağlam” ve “kod” özellikleri hakkında daha fazla bilgi için “Pencere Araçları Listesi” altındaki “Düğme” girişine bakın.
----

# Widgetların Listesi

| Name | Class | Tag |
|------|-------|-----|
|**Image**, vanilla|FlxUISprite|```<sprite>```|
|**Image**, 9-slice/chrome|FlxUI9SliceSprite|```<9slicesprite>``` or ```<chrome>```|
|**Region**|FlxUIRegion|```<region>```|
|**Button**, vanilla|FlxUIButton|```<button>```|
|**Button**, toggle|FlxUIButton|```<button_toggle>```|
|**Check box**|FlxUICheckBox|```<checkbox>```|
|**Text**, vanilla|FlxUIText|```<text>```|
|**Text**, input|FlxUIInputText|```<input_text>```|
|**Radio button group**|FlxUIRadioGroup|```<radio_group>```|
|**Tabbed menu**|FlxUITabMenu|```<tab_menu>```|
|**Line**|FlxUISprite|```<line>```|
|**Numeric Stepper**|FlxUINumericStepper|```<numeric_stepper>```|
|**Dropdown/Pulldown Menu**|FlxUIDropDownMenu|```<dropdown_menu>```|
|**Bar**|FlxUIBar|```<bar>```|
|**Tile Grid**|FlxUITileTest|```<tile_test>```|
|**Custom Widget|Any (implements IFlxUIWidget)|```<whatever_you_want>```|

Bunların üzerinden tek tek geçelim. Birçoğu ortak niteliklere sahiptir, bu nedenle belirli nitelikleri yalnızca ilk kez ortaya çıktıklarında tüm ayrıntılarıyla açıklayacağım.

## 1. Image (FlxUISprite) ```<sprite>```

Sadece normal bir sprite. Ölçeklenebilir veya sabit boyutta olabilir.

Nitelikleri:
* ```x``` ve ```y```
* ```src``` (kaynağa yol, uzantısız, “assets/gfx/” dosyasına eklenir. Eğer mevcut değilse bunun yerine “color” arar)
* ```color``` (dikdörtgenin rengi. “color” niteliği onaltılık formatta ``0xAARRGGBB`` veya ``0xRRGGBB`` veya ``flixel.util.FlxColor`` öğesinden ‘white’ gibi standart bir renk dizesi adı olmalıdır)
* ```use_def``` (tanımlama adı)
* ```group``` (grup adı)
* ```width``` ve ```height``` (isteğe bağlı, tam piksel değerleri veya formüller kullanın -- bunlar kaynak görüntünün doğal genişlik/yüksekliğinden farklıysa görüntüyü ölçeklendirir)
* `smooth` (isteğe bağlı, varsayılan değer true -- kaynakla 1:1 değilse görüntünün nasıl ölçeklendirileceğini belirtir. Pürüzler için False, pürüzsüzlük için True. antialias` ile eşanlamlıdır) 
* ```resize_ratio``` (isteğe bağlı, genişlik veya yükseklik belirtirseniz, bunu ölçekleme en boy oranını zorlamak için de tanımlayabilirsiniz)
* ```resize_ratio_x``` / ```resize_ratio_y``` (isteğe bağlıdır, resize_ratio ile aynı şeyi yapar, ancak yalnızca bir ekseni etkiler)
* ```resize_point``` - (isteğe bağlı, dize) yeniden boyutlandırmak için anchor tanımlayın
    *  "nw" / "ul" -- Sol üst
    *  "n"  / "u"  -- Üst
    *  "ne" / "ur" -- Sağ üst
    *  "sw" / "ll" -- Sol alt
    *  "s"         -- ALt
    *  "se" / "lr" -- Sağ alt
    *  "m" / "c" / "mid" / "center" -- Merkez

## 2. 9-slice sprite/chrome (FlxUI9SliceSprite) ```<nineslicesprite>``` or ```<chrome>```

9 dilimli bir sprite, doğrudan germekten daha hoş bir şekilde ölçeklendirilebilir. Nesneyi kullanıcı tanımlı 9 hücrelik bir ızgaraya böler (4 köşe, 4 kenar, 1 iç) ve ardından yeniden boyutlandırılmış bir görüntü oluşturmak için bunları ayrı ayrı yeniden konumlandırır ve ölçeklendirir. En iyi krom ve düğme gibi şeyler için çalışır.

Nitelikler:
* ```x```/```y```, ```use_def```, ```group```
* ```src```
* ```width```/```height``` **İSTEĞE BAĞLI DEĞİL**: 9 dilimli ölçeklendirilmiş görüntünüzün boyutu (kaynak görüntünün boyutu değil)
* ```slice9``` - string, slice9 ızgarasını tanımlayan iki nokta, format “x1,y1,x2,y2”. Örneğin, “6,6,12,12” demo projesindeki 12x12 krom görüntüler için iyi çalışır.
* ```tile``` - bool, isteğe bağlı (yoksa false varsayılır). true ise, 9 dilimli hücreleri germek için ölçekleme yerine döşeme kullanır. Boolean true == “true”, “True” veya “TRUE” veya “T” değil.
* ```smooth``` - bool, isteğe bağlı (yoksa false varsayılır). true ise, ölçeklendirmenin en yakın komşu (gerilmiş bloklu pikseller) yerine yumuşak enterpolasyon kullanmasını sağlar.
* ```color``` - renk, isteğe bağlı, kromu renklendirmek için (örneğin beyaz hiçbir şey yapmaz.) “renk” niteliği onaltılık formatta ``0xAARRGGBB`` veya ``0xRRGGBB`` veya ``flixel.util.FlxColor`` `dan “yeşil” gibi standart bir renk dizesi adı olmalıdır)
  
## 3. Region (FlxUIRegion) ```<region>```

Regionlar, sadece Flixel'in Hata Ayıklama “ana hatları göster” modunda görülebilen hafif, görünmez dikdörtgenlerdir. 

Görünmez olmalarına rağmen, Regionlar tam teşekküllü IFlxUIWidget nesneleridir ve en çok yer tutucu olarak ve karmaşık düzenler kurmak için ara nesneler olarak kullanışlıdır. Temel olarak, bir ```<sprite>`` veya ```<chrome>`` etiketi oluşturmak istediğinizde, bu nesneyi gerçekten görmeniz gerekmiyorsa, ancak yalnızca başka bir şeyi konumlandırmak için kullanmak veya sonraki bir formülde kullanabileceğiniz hedeflenebilir bir widget oluşturmak istiyorsanız, bunun yerine bir Region kullanın.
Nitelikler:
* ```x```/```y```, ```use_def```, ```group```
* ```width```/```height```

## 4. Button (FlxUIButton) ```<button>```

Sadece sıradan basmalı düğme, tercihen bir etiket ile.

Nitelikler:
* ```x```/```y```, ```use_def```, ```group```
* ```width```/```height``` - tercihe bağlı, bir 9-slice sprite'ını kaynak olarak kullandığında gerekir
* ```text_x```/```text_y``` - x & y offsetlerini etiketleyin
* ```label``` - göstermek için yazı
* ```context``` - (isteğe bağlı) etiket bir [firetongue](http://www.github.com/larsiusprime/firetongue) bayrağı ise bağlam değeri
* ```code``` - (isteğe bağlı) firetongue biçimlendirme kodu. Metne bir biçimlendirme kuralı uygular:
    * “u” - tamamı büyük harf
    * “l” - tamamı küçük harf
    * “fu” - ilk harf büyük
    * “fu_” - her kelimenin ilk harfi büyük
* ```resize_ratio```, ```resize_point``` (Image'e bakın)
* ```resize_label``` - (isteğe bağlı, boolean) düğme yeniden boyutlandırıldığında etiketin ölçeklenmesine izin verilip verilmeyeceği
* ```color``` - renk, isteğe bağlı, kromu renklendirmek için (örneğin beyaz hiçbir şey yapmaz.) “renk” niteliği onaltılık formatta ``0xAARRGGBB`` veya ``0xRRGGBB`` veya ``flixel.util.FlxColor`` `dan “yeşil” gibi standart bir renk dizesi adı olmalıdır)

Alt etiketler:
* ``<text>`` - tıpkı normal bir \<text> düğümü gibi
* ``<param>`` - geri arama/olay sistemine aktarılacak parametre (bkz. “Düğme Parametreleri”)
* ```<graphic>``` - grafik kaynağı (ayrıntılar aşağıda)

### 4.1 Parametreler ile çalışmak

UI olaylarına bağlam kazandırmak için düğmelere ve diğer birçok etkileşimli nesne türüne parametreler eklenebilir. Bunu, uygun widget'a ``<param>`` alt etiketleri ekleyerek yapabilirsiniz.

A ```<param>``` etiketi 2 nitelik alır: ```type``` ve ```value```. 

* ```type```: ```"0xFF00FF"``` gibi bir değer için "string", "int", "float", ve "color" ya da "hex" 
* ```value```: değeri, bir dize olarak. type niteliği, doğru şekilde yazılmasını sağlayacaktır.

```xml
<button name="new_game" use_def="big_button_gold" x="594" y="11" group="top" label="New Game">
	<param type="string" value="new"/>
</button>
```

İstediğiniz kadar ```<param>`` etiketi ekleyebilirsiniz. Bu düğmeye tıkladığınızda, varsayılan olarak FlxUI'nin dahili genel statik olay geri çağrısını çağıracaktır:

```haxe
FlxUI.event(CLICK_EVENT, this, null, params);
```

Bu da, bu ``FlxUI`` nesnesinin “sahibi” olan ``IEventGetter`` üzerinde ``getEvent()`` işlevini çağıracaktır. Varsayılan kurulumda, bu sizin ``FlxUIState`` nesnenizdir. Bu yüzden bu fonksiyonu ``FlxUIState`` nesnenizde genişletin:

```haxe
getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
```

“Gönderen” parametresi, olayı başlatan widget olacaktır - bu durumda düğme. Bir ``FlxUIButton`` tıklandığında, diğer parametreler şöyle olacaktır:

* **event name**: "click\_button" (ieörneğin, ```FlxUITypedButton.CLICK_EVENT```)
* **data**: ```null```
* **params**: bir ```Array<Dynamic>``` tanımladığınız tüm parametreleri içerir.

Diğer bazı interaktif widget'lar parametre alabilir ve temelde aynı şekilde çalışırlar.

### 4.2 Düğme Grafikleri
Düğmeler için grafikler biraz karmaşık olabilir. Belirtmek istediğiniz her düğme durumu için bir tane olmak üzere birden fazla grafik etiketi koyabilir veya tüm durumları dikey olarak yığılmış tek bir görüntüde birleştiren ve FlxUIButton'dan tek tek kareleri kendisinin sıralamasını isteyen “all” adında bir tane koyabilirsiniz.

Sistem bazen görüntüye göre çerçeve boyutunun ne olması gerektiğini çıkarabilir ve genişlik/yükseklik ayarlanmamıştır, ancak statik olarak boyutlandırılmışlarsa ve 9 dilimli ölçekleme kullanmıyorsanız genişlik/yükseklik ile açık olmak yardımcı olur.

Statik, bireysel çerçeveler:

```xml
<definition name="button_blue" width="96" height="32">
	<graphic name="up" image="ui/buttons/static_button_blue_up"/>
	<graphic name="over" image="ui/buttons/static_button_blue_over"/>
	<graphic name="down" image="ui/buttons/static_button_blue_down"/>
</definition>
```

9 dilimli ölçeklendirme, ayrı kareler:

```xml
<definition name="button_blue" width="96" height="32">
	<graphic name="up" image="ui/buttons/9slice_button_blue_up" slice9="6,6,12,12"/>
	<graphic name="over" image="ui/buttons/9slice_button_blue_over slice9="6,6,12,12""/>
	<graphic name="down" image="ui/buttons/9slice_button_blue_down slice9="6,6,12,12""/>
</definition>
```

9 dilimli ölçeklendirme, hepsi bir arada çerçeve:

```xml
<definition name="button_blue" width="96" height="32">
	<graphic name="all" image="ui/buttons/button_blue_all" slice9="6,6,12,12"/>
<definition>
```

Çerçeveleri tek tek yaparsanız ve birini atlarsanız ne olacağından %100 emin değilim, ancak sanırım diğerlerinden birini bir tür “akıllı” şekilde kopyalayacak şekilde ayarladım. Yine, muğlak olmak ve sistemin tahmin etmesini sağlamak yerine ne istediğiniz konusunda açık olmak her zaman en iyisidir.

### 4.3 Düğme Metni
Bir düğmedeki metnin neye benzediğini belirtmek için bir ``<text>`` alt düğümü oluşturursunuz.
Tüm özellikleri burada belirtebilir veya bir tanım kullanabilirsiniz. Bir düğmenin içindeki ```<text>``` düğümleri için birkaç özel husus vardır.

Ana “color” özelliği (onaltılık biçim, “0xffffff”) ana etiket rengidir

Diğer durumlar için renk belirtmek isterseniz, her durum için ```<text>``` etiketinin içine ``<color>`` etiketlerini eklersiniz:

```xml
<button x="200" y="505" name="some_button" use_def="text_button" label="Click Me">
	<text use_def="vera10" color="0xffffff">
		<color name="over" value="0xffff00"/>
	</text>
</button>	
````


## 5. Button, Toggle (FlxUIButton) ```<button_toggle>```

Geçiş düğmeleri normal düğmelerle aynı sınıftan yapılır, ``FlxUIButton``.

Geçiş düğmeleri, geçiş yapıldığında yukarı/aşağı/aşağı için 3 ve geçiş yapılmadığında yukarı/aşağı/aşağı için 3 olmak üzere 6 duruma sahip olmaları bakımından farklıdır. Varsayılan olarak, yeni yüklenmiş bir geçiş düğmesinin “toggle” değeri yanlıştır.

Geçiş düğmeleri normal bir düğmeden daha fazla grafiğe ihtiyaç duyar. Bunu yapmak için, hem normal hem de değiştirilmemiş durumlar için grafik etiketleri sağlamanız gerekir. Geçişli ```<graphic>``` etiketleri aynıdır, sadece ek bir toggle=“true” niteliğine ihtiyaç duyarlar:

```xml
<definition name="tab_button_toggle" width="50" height="20" text_x="-2" text_y="0">			
	<text use_def="sans10c" color="0xcccccc">
		<color name="over" value="0xccaa00"/>
		<color name="up" toggle="true" value="0xffffff"/>
		<color name="over" toggle="true" value="0xffff00"/>
	</text>
		
	<graphic name="up" image="ui/buttons/tab_grey_back" slice9="6,6,12,12"/>
	<graphic name="over" image="ui/buttons/tab_grey_back_over" slice9="6,6,12,12"/>
	<graphic name="down" image="ui/buttons/tab_grey_back_over" slice9="6,6,12,12"/>
		
	<graphic name="up" toggle="true" image="ui/buttons/tab_grey" slice9="6,6,12,12"/>
	<graphic name="over" toggle="true" image="ui/buttons/tab_grey_over" slice9="6,6,12,12"/>				
	<graphic name="down" toggle="true" image="ui/buttons/tab_grey_over" slice9="6,6,12,12"/>				
</definition>
```

Elbette, dikey olarak istiflenmiş 6 görüntü içeren tek bir varlık oluşturursanız, kendinize biraz yer kazandırabilirsiniz:

```xml
<definition name="button_toggle" width="50" height="20">		
	<text use_def="sans10c" color="0xffffff">
		<color name="over" value="0xffff00"/>
	</text>
	
	<graphic name="all" image="ui/buttons/button_blue_toggle" slice9="6,6,12,12"/>		
</definition>
```

Dikey bir 9 dilimli varlık yığını veya normal statik boyutlu varlıklar oluşturabileceğinizi unutmayın; sistem bunlardan birini kullanabilir. 

## 6. Onay kutusu (FlxUICheckBox) ```<checkbox>```

Onay Kutusu, üç nesne içeren bir FlxUIGroup'tur: bir “kutu” görüntüsü, bir “onay” görüntüsü ve bir etiket.

Öznitelikler:
* ```x```/```y```, ```use_def```, ```group```
* ```check_src``` - onay işareti için kaynak görüntü (9-bölünemez, boyutlandırılamaz)
* ```box_src``` - kutu için kaynak görüntü (9-bölünemez, boyutlandırılamaz)
* ```text_x``` / ```text_y``` - etiket ofsetleri
* ```label``` - gösterecek yazılar
* ```context``` - FireTongue bağlamı (bkz. Button)
* ```code``` - Kod formatlama (bkz. Button)
* ```checked``` - (boolean) dolu mu, değil mi?
* ```label_width``` - etiket genişliği

Child tags:
* ```<text>``` - ```<button>``` ile aynı
* ```<param>``` - ```<button>``` ile aynı
* ```<check>``` - check_src'ye alternatif, daha güçlü*
* ```<box>``` - box_src'ye alternatif, daha güçlü*
  
*Öznitelik eşdeğerleri yerine ``<check>`` veya ``<box>`` alt etiketlerini sağlarsanız, FlxUI bunları onay işareti ve kutu varlıkları için yüklenecek tam teşekküllü ``<sprite>`` veya ``<chrome>`` etiketleri olarak değerlendirecektir. Normalde statik bir görüntüyü olduğu gibi yükleyen src nitelikleriyle gerçekleştiremeyeceğiniz ölçeklendirilmiş bir sprite veya 9 dilimli ölçeklendirilmiş bir sprite yüklemek gibi karmaşık bir şey yapmak istiyorsanız bu yöntemi kullanmak isteyeceksiniz.

Olay:
* isim - “click_check_box”
* params - kullanıcı tarafından tanımlandığı gibi, ancak bu otomatik olarak listenin sonuna eklenir: ``{name: “checked”, value:false}`` veya ``{name: “checked”, value:true}``

## 7. Text (FlxUIText) ```<text>```

Normal bir metin alanı. 

Nitelikler:
* ```text``` - yazı alanındaki asıl yazı
* ```x```/```y```, ```use_def```, ```group```
* ```font``` - dize, "vera" veya "verdana" gibi birşey
* ```size``` - tamsayı, fontun boyutu
* ```style``` - dize, "regular", "bold", "italic", veya "bold-italic"
* ```color``` - hex dizesi, örneğin, "0xffffff" beyazdır
* ```align``` - "left", "center", veya "right". "justify" ı test etmedim
* ```context``` - FireTongue bağlamı (bkz. Button)
* ```code``` - Kodu formatlama (bkz. Button)

Yazı alanlarının da kenarlıkları olabilir. Şu dört değeri atayarak bunu yapabilirsiniz:

* ```border``` - dize, kenarlık stili:
  * ```false```/```none``` - kenarlıksız
  * ```shadow``` - gölge efekti
  * ```outline``` - kenarlık (yüksek kalite)
  * ```outline_fast``` - kenarlık (düşük kalite)
* ```border_color``` - kenarlığın rengi
* ```border_size``` - piksel bazında kalınlık
* ```border_quality``` - 0.0 (en düşük) ve 1.0 (en yüksek) arasındaki sayı

Ayrıca, yer kazanmak için kenarlık değeri için kısayol kullanabilirsiniz. Bunun için “shadow”, ‘outline’ veya “outline_fast” özniteliklerini doğrudan kullanın ve bunlara bir renk atayın.

```xml
<text name="my_text" text="My Text" outline="0xFF0000"/>
```

Yazı tipleri için FlxUI, ```assets/fonts/``` dizininde şu şekilde biçimlendirilmiş bir yazı tipi dosyası arayacaktır:

|Filename|Family|Style|
|---|---|---|
vera.ttf|Vera|Regular
verab.ttf|Vera|Bold
verai.ttf|Vera|Italic
veraz.ttf|Vera|Bold-Italic

Şu ana kadar sadece .ttf dosyaları desteklenmektedir, ve (en azından şimdilik) bu şemaya göre ADLANDIRMALISINIZ. 

FlxUI şu anda FlxBitmapFonts'u desteklememektedir, ancak yakın zamanda ekleyeceğiz. 

### 8. Yazı, giriş (FlxUIInputText) ```<input_text>```

Sıkı bir biçimde test edilmedi, ama var.

Öznitelikler:
* ```x```/```y```, ```use_def```, ```group```
* ```font```, ```size```, ```style```, ```color```, ```align```
* (kenar öznitelikleri)
* ```password_mode``` - bool, true ise yazıyı gizler
* ```background``` - (tercihen, FlxColor) arkaplan rengi
* ```force_case``` - (dize) yazıyı özel bir durumda görünmeye zorla
    * "upper" / "upper_case" / "uppercase"
    * "lower" / "lower_case" / "lowercase"
* ```filter``` - (dize) sadece bazı tip yazılara izin ver (ingilizce-dışı dillerde test edilmedi)
    * "alpha" / "onlyalpha" - sadece standart alfabe karakterleri
    * "num" / "numeric" - sadece standart rakamlar
    * "alphanum" / "alphanumeric", "onlyalphanumeric" -- sadece standart alfabe karakterleri & rakamlar
* ```context``` - FireTongue bağlamı (bkz. Button)
* ```code``` - Kodu formatlama (bkz. Button)

## 9. Radyo buton grubu (FlxUIRadioGroup) ```<radio_group>```

Radyo grupları, tek seferde sadece birinin tıklanabildiği bir takım butonlardır. Bunları ```FlxUIGroup``` of ```FlxUICheckBox```'ları olarak uygularız,ve iç sistemse tek seferde sadece birini tıklanabilir hâle getirir.  

Öznitelikler:
* ```x```/```y```, ```use_def```, ```group```
* ```radio_src``` - radyo arkası için görüntü kaynağı (örneğin, checkbox "box") 
* ```dot_src``` - radyo noktası için görüntü kaynağı (örneğin, checkbox "check mark")

Bir radyo grubunu istediğiniz kadar ```<radio>``` alt etiketlerinden vererek üretirsiniz. Her birine birer ad ve etiket verin. 

Alt Düğümler:
* ```<param>``` - ```<button>``` ile aynı, 
* ```<radio>``` - iki öznitelik, ad (dize) ve etiket (dize)
* ```<dot>``` - dot_src muadili, daha güçlü*
* ```<box>``` - radio_src muadili, daha güçlü*
*Eğer özellik eşdeğerlerinin yerine ```<dot>``` veya ```<box>``` alt etiketlerini kullanırsanız, nokta ve radyo kutularını yüklemek için FlxUI onlara tam ```<sprite>``` veya ```<chrome>``` etiketi gibi davranacaktır. Ölçeklendirilmiş sprite yüklemek veya normalda src özellikleriyle başaramayacağınız sadece bir statik görseli olduğu gibi yükleyen 9 parçalı ölçekli bir sprite yüklemek gibi karışık bir şey yapmak isterseniz bu metodu kullanmak isteyebilirsiniz. 
Olay:
* ```name``` - "radyo grubuna tıkla"
* ```params``` - Button ile aynı

## 10. Sekmeli Menü (FlxUITabMenu) ```<tab_menu>```

Sekmeli menüler en karışık ```FlxUI``` araç takımıdır. ```FlxUITabMenu``` , ```FlxUI``` 'yi genişletir ve bu nedenle, ```<layout>``` etiketi gibi, kendi başına tam teşekküllü bir ```FlxUI``` 'dir.

Bu, üstte çeşitli sekmeli düğmeler içeren bir menü sağlar. Bir sekmeye tıkladığınızda, o sekmenin içeriği gösterilir ve geri kalanı gizlenir. 

Özellikler:
* ```x```/```y```, ```use_def```, ```group```
* ```width```/```height```
* ```back_def``` - 9 parçalı bir sprite için isim (9'a BÖLÜNEBİLMELİ!) 
* ```slice9```

Alt Düğümler:
* ```<tab>``` - attributes are "name" and "label", much like in ```<radio_group>```'da olduğu gibi özellikler "name" ve "label"dır.
* ```<group>``` - özellikler sadece "name"dir
 * ```<group></group>``` düğümüyle beraber sıradan FlxUI içerik etiketlerini koyun.

## 11. Sıra (FlxUISprite) ```<line>```

TODO

## 12. NumStepper (FlxUINumericStepper) ```<numeric_stepper>```

TODO

## 13. Listeleme/Çekme (FlxUIDropDownMenu) ```<dropdown>```

TODO

## 14. Bar ([FlxUIBar](https://api.haxeflixel.com/flixel/addons/ui/FlxUIBar.html)) ```<bar>```

Sağlığı ve ilerlemeyi gösterebilecek bir Bar sağlar.

Özellikler:
* ```x```/```y``` - barın pozisyonu
* ```width```/```height``` - barın boyutu
* ```fill_direction``` - doldurma yönü. Varsayıılan `left_to_right`dır. Mümkün olan değerler için aşağıya bakın.
* ```parent_ref``` - Oyununuzda barın takip etmesini istediğiniz (değeri) nesneye bir referans
* ```variable``` - Bar pozisyonunu belirlemekte kullanılan objenin değişkeni. Örneğin, eğer üst FlxSprite ise, sağlık değerini takip edebilmek için "health" olabilir
* ```min``` - Minimum değer. Örneğin, bir ilerleme barı için bu "sıfır" olabilir (henüz hiçbir şey yüklenmemiş)
* ```max``` - Barın ulaşabileceği maksimum değer. Örneğin, bir ilerleme barı için bu genelde "100" olabilir.
* ```value``` - Barın başlangıçtaki değeri. Varsayılan `max`dır
* ```border_color``` - Kenarlığın rengi. Kaldırılısa kenarlık yoktur.
* ```filled_color``` veya ```color``` - hexformat içinde dolu olduğu takdirde barın rengi. Varsayılan kırmızıdır.
* ```empty_color``` - hexformat içinde boş olduğu takdirde barın rengi. Varsayılan kırmızıdır.
* ```filled_colors``` veya ```colors``` ve ```empty_colors``` -Verilen renk aralıklarını kullanarak gradyan bir sağlık barı oluşturur.
* ```chunk_size``` - Eski görünümlü parça gradyanı isterseniz, bu değeri yükseltin!
* ```rotation``` - Gradyanın dereceyle eğrisi. Yukarıdan aşağı 90, soldan sağaysa 180.Herhangi bir açı olur
* ```src_filled```/```src_empty``` - Boş/dolu bir bar için bir görsel kullanın.

Olası `fill_direction` değerleri:
* “left_to_right”
* “right_to_left”
* “top_to_bottom”
* “bottom_to_top”
* “horizontal_inside_out”
* “horizontal_outside_in”
* “vertical_inside_out”
* “vertical_outside_in”


## 15. TileTest (FlxUITileTest) ```<tile_test>```

TODO

## 16. Özel Widget (IFlxUIWidget'ı uygulayan herhangi bir sınıf) ```<whatever_you_want>```

UI'nize belirli etiketler eklediğinizde, özel bir widget'ı görüntülemek için bir işleyici de ekleyebilirsiniz. Görüntülemek için kullanabileceğiniz IFlxUIWidget'ı uygulayan bir sınıfınız olduğu sürece, istediğiniz etiketleri belirtebilirsiniz.
	
Yerleşimdeki adı varsayılan olarak sağlananlarla eşleşmeyen herhangi bir widget, FlxUI sınıfına yönlendirilir; `getRequest(name:String, sender:Dynamic, data:Dynamic):Dynamic` öğesini geçersiz kılın, `ui_get:whatever_you_want` adlı bir istek arayın ve özel widget'ınızı döndürün.
	
İşte bir örnek. XML'deki `<save_slot>` örneğinin SaveSlot widget'ıyla doldurulduğunu görebilirsiniz.

```
public override function getRequest(id:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic
{
    if (id.indexOf(“ui_get:”) == 0)
    {
        switch (id.remove(“ui_get:”))
        {
            case “save_slot”:
                return new SaveSlot(data, _ui);
        }
    }
    return null;
}
```    

----

# Araç İpuçları

Araç ipuçları, ```<button>```, ```<button_toggle>```, ```<checkbox>```, ```FlxUIRadioGroup``` öğesinin ```<radio>``` alt etiketleri ve ```FlxUITabMenu``` öğesinin ```<tab>``` alt etiketleri dahil olmak üzere düğme ve düğme benzeri widget'lara eklenebilir.

( [flixel-demos](https://github.com/haxeflixel/flixel-demos) adresinde, “Kullanıcı Arayüzü” kategorisi altında tam özellikli bir “Araç İpuçları” demosu bulunduğunu unutmayın.)

Özellikler:
* ```x```/```y``` - araç ipucunun bağlantı noktası için x/y ofseti
* ```use_def``` - diğer her şey gibi araç ipucu için bir tanım belirtebilirsiniz
* ```width```/```height```
* ```text``` - dize, iki metin alanı (başlık ve gövde metni) değil, yalnızca bir metin alanı istiyorsanız bunu ayarlayın
* ```background``` - arka plan rengi
* ```border``` - kontur kenarlığının boyutu, piksel cinsinden
* ```border_color``` - kontur kenarlığının rengi
* ```arrow``` - dize, ok için sprite varlık kaynağı
* ```auto_size_horizontal``` - bool, araç ipucunun genişliğini görünür metin + dolgu sınırlarına göre kırpıp kırpmayacağınız (varsayılan true)
* ```auto_size_vertical``` - bool, araç ipucunun yüksekliğini görünür metin + dolgu sınırlarına göre kırpıp kırpmayacağı (varsayılan true)
* ```pad_left``` - sol kenar dolgusu, piksel cinsinden
* ```pad_right``` - sağ kenar dolgusu, piksel cinsinden
* ```pad_top``` - üst kenar dolgusu, piksel cinsinden
* ```pad_bottom``` - alt kenar dolgusu, piksel cinsinden
* ```pad_all``` - kısayol, 4 dolgu değerinin tümünü tek bir öznitelikte ayarla
 
Alt Düğümler:
* ```title``` - bir FlxUIText düğümü, başlık metni içeriğini ve stilini belirtir.
  * ```x```/```y``` - başlık metni için x/y ofsetini belirtebilirsiniz.
  * “text” kısayol özniteliği aracılığıyla araç ipucu metnini belirlediyseniz, “title” metin alanı kullanılır ve gövde gizlenir.
  * bu durumda, “title” düğümü aracılığıyla bir stil ayarlayabilirsiniz
* ```body``` - bir FlxUIText düğümü, gövde metin içeriğini ve stilini belirtir
  * ```x```/```y``` - gövde metni için x/y ofseti belirtebilirsiniz
  * ```body``` metin alanının varsayılan konumunun başlık metin alanının hemen altında olduğunu unutmayın
* ```anchor``` - bu, araç ipucunuzun üst nesnesine nasıl bağlandığını belirtir. 
  * Bunu, başka yerlerde anchor etiketlerini kullandığınız şekilde, ```x```/```y``` ve ```x-flush```/```y-flush``` kullanarak yapabilirsiniz. 
  * ```<tooltip>``` düğümünde ayarlanan ```x```/```y``` *özellikleri*, diğer tüm widget'larda olduğu gibi, bağlantı için x/y *ofsetleri* olarak işlev görür.

Çok basit bir araç ipucu şu şekilde eklenir:

```xml
<button name="basic" x="160" y="120" label="Basic">
    <tooltip text="Basic tooltip"/>
</button>
```

Bu araç ipucu her iki metin alanını da kullanır:

```xml
<button name="fancier" x="basic.x" y="basic.bottom+10" label="Fancier">
	<tooltip>
        <title text="Daha süslü araç ipucu!" width="100"/>
        <body text="Bu araç ipucunda bir başlık VE bir gövde vardır." width="100" />
    </tooltip>
</button>
```

Bu araç ipucu hemen hemen her şeyi ayarlar:

```xml
<button name="fanciest" x="basic.x" y="even_fancier.bottom+10" label="Fanciest">
    <tooltip pad_all="5" background="red" border="1" border_color="white">
		<title use_def="sans12" text="En süslü araç ipucu!" width="125"/>
        <body use_def="sans10" text="Bu araç ipucunda bir başlık ve gövde, özel dolgu ve ofsetler ile özel metin biçimlendirmesi vardır" width="120" x="5" y="5"/>
		<anchor x="center" x-flush=“center” y="bottom" y-flush=“top”/>
    </tooltip>
</button>
```

----

# Dinamik pozisyon ve boyut

## 1. Bağlantı Etiketleri

İşte bir RPG oyunundaki sağlık çubuğunun bir örneği:

```xml
<nineslicesprite name="health_bar" x="10" y="5" width="134" height="16" use_def="health">
    <anchor x="portrait.right" y="portrait.top" x-flush=“left” y-flush=“top”/>
</nineslicesprite>
```

Muhtemelen başka bir yerde “portrait” adında başka bir sprite tanımlanmıştır ve sağlık çubuğumuzun bu sprite'ın bulunduğu yere göre gösterilmesini istiyoruz. 

Anchor'un x ve y değerleri belirli bir noktayı belirtir, x-flush ve y-flush ise nesnenin hangi köşesinin bu noktaya hizalanacağını belirtir. Ana nesnenin x / y değerleri, nesne anchor'a hizalandıktan sonra ofset olarak eklenir.

X/y için kabul edilebilir değerler:
* “left”, “right”, ‘top’ veya “bottom”: flixel tuvalinin kenarları.
* nesne özellikleri (yani, “some_id.some_property”):
 * “left”, “right”, ‘top’, “bottom”: o nesnenin kenarları
 * “center”: o nesnenin merkezi (x veya y özniteliğinden çıkarılan eksen)

x-flush/y-flush için kabul edilebilir değerler:
* “sol”
* “sağ”
* “üst”
* “alt”
* “merkez”

Ayrıca, nihai hesaplanan konumu yuvarlamak için bağlantı etiketinin içinde **round** özniteliği (yukarı/aşağı/yuvarlak/doğru/yanlış) belirtebilirsiniz.

**İngilizceyi ana dili olarak konuşmayanlar için not:** “flush” marangozluk terimidir, yani bir nesnenin bir tarafı başka bir nesnenin tarafına paralel ve aralarında boşluk kalmayacak şekilde temas ediyorsa, nesneler “flush” durumundadır. Bunun tuvaletlerle hiçbir ilgisi yoktur :)

--
## 2. Konum Etiketleri

Bazen xml işaretlemesinde bir widget'ın konumunu daha sonra değiştirmek isteyebilirsiniz. Konum etiketleri, nesnenin orijinal oluşturma etiketi gibi çalışır, ancak SADECE taşımak istediğiniz nesnenin öznitelik adını ve ilgili konum bilgilerini eklemeniz gerekir.

```xml
<position name="thing" x="12" y="240"/>
```

Konum etiketi içinde bağlantı etiketleri, formüller vb. kullanabilirsiniz:
```xml
<position name="thing" x="other_thing.right" y="other_thing.bottom">
  <anchor name="other_thing" x-flush=“left” y-flush=“top”/>
</position>
```

--
## 3. Boyut Etiketleri

Sağlık çubuğumuza bir boyut etiketi ekleyelim:
```xml
<nineslicesprite name="health_bar" x="10" y="5" width="134" height="16" use_def="health" group="mcguffin">
	<anchor x="portrait.right" y="portrait.top" x-flush=“left” y-flush=“top”/>
    <exact_size width="stretch:portrait.right+10,right-10"/>
</nineslicesprite>
```

Üç boyut etiketi vardır: ```<min_size>```, ```<max_size>``` ve ```<exact_size>```

Bu, bir nesnenin boyutu için dinamik alt/üst sınırları belirlemenizi veya tam boyutta olmasını zorlamanızı sağlar. Bu, birden fazla çözünürlükte çalışabilen bir kullanıcı arayüzü oluşturmanıza veya manuel piksel hesaplamaları yapmanız gerekmemesine olanak tanır. 

Boyut etiketleri yalnızca üç öznitelik alır: **width**, **height** ve **round**. Genişlik veya yükseklik belirtilmezse, boyutun o kısmı yok sayılır ve aynı boyutta kalır.

Genişlik/yükseklik özniteliğini formüle etmenin birkaç yolu vardır:

* **sayı** (ör. width="100")
* **uzatma** (ör. width="stretch:some_value,another_value")
* **referans** (ör. width="some_id.some_value")

Bir **stretch** formülü, FlxUI'ye virgülle ayrılmış iki değer arasındaki farkı hesaplamasını söyler. Bu değerler, **reference** formülü gibi biçimlendirilir ve hesaplanır. Eksen, genişlik mi yoksa yükseklik mi olduğuna göre çıkarılır. 

Dolayısıyla, ekranın üst kısmında bir skor tahtası varsa ve oyun alanının skor tahtasının altından ekranın altına kadar uzanmasını istiyorsanız:

```xml
<exact_size height="stretch:scoreboard.bottom,bottom"/>
```

Referans formülü için tek başına veya stretch ile birlikte kullanılabilen kabul edilebilir özellik değerleri:
* **çıplak referans** (yani, “some_id”) - o şeyin çıkarılan x veya y konumunu döndürür.
* **özellik referansı** (yani, “some_id.some_value”) - bir nesnenin özelliğini döndürür.
 * “left”, “right”, “top”, “bottom”, “width”, “height”, “halfwidth”, “halfheight”, “centerx”, ‘centery’
 * “center” (centerx veya centery'yi çıkarır)
* **aritmetik formül** (örneğin, “some_id.some_value+10”) - bazı matematik işlemleri yapar
 * Yukarıdakilerin herhangi birine **bir** operatör ve **bir** işlenen (sayısal değer veya widget özelliği) ekleyebilirsiniz.
 * Geçerli operatörler = (+, -, *, \, ^)
 * Burada çok fazla abartmaya çalışmayın. Çok karmaşık matematiksel işlemler yapmanız gerekiyorsa, FlxUIState'inize biraz kod ekleyin, getAsset(“some_id”) işlevini çağırarak varlıklarınızı alın ve karmaşık işlemleri kendiniz yapın.

--
## 4. Hizalama Etiketleri

```<align>``` etiketi, çeşitli nesneleri otomatik olarak hizalamanızı ve aralıklarını ayarlamanızı sağlar.

```xml
<align axis="horizontal" spacing="2" resize="true">
    <bounds left="options.left" right="options.right"/>
    <objects value="spell_0,spell_1,spell_2,spell_3,spell_4,spell_5"/>
</align>
```

Özellikler:
* axis - “horizontal” veya “vertical”
* spacing - sayı
* resize - bool, isteğe bağlı, “true” veya “false” (yoksa false olarak kabul edilir)

Alt etiketler:
* ```<bounds>``` - dize, referans formülü, yatay için sol ve sağ, dikey için üst ve alt belirtir
* ```<objects>``` - dize, virgülle ayrılmış nesne adları listesi

Birden fazla “objects” etiketi belirtirseniz, aynı kurallara göre birkaç nesne grubunu aynı anda hizalayabilirsiniz. Örneğin, obj_0'dan obj_9'a kadar (toplam 10) nesneniz varsa ve beş sütunda eşit aralıklı iki satır istiyorsanız, bunu şu şekilde yapabilirsiniz:

```xml
<align axis="horizontal" spacing="2" resize="true">
    <bounds left="options.left" right="options.right"/>
    <objects value="obj_0,obj_1,obj_2,obj_3,obj_4"/>
	<objects value="obj_5,obj_6,obj_7,obj_8,obj_9"/>
</align>
```

Oysa 10 nesneyi tek bir ```<objects>``` etiketine koyarsanız, 10 sütunlu tek bir satır elde edersiniz.

----

# Yerelleştirme (FireTongue)
İlk olarak, Firetongue'un Github sayfasında bazı [belgeler](https://github.com/larsiusprime/firetongue) bulunmaktadır. Bunları okuyun. 

Yerel projenizde şu adımları izleyin:

**1. FireTongue sarmalayıcı sınıfı oluşturun**

 Bunun için yapmanız gerekenler:
 1. **firetongue.FireTongue**'u genişletin.
 2. **flixel.addons.ui.IFireTongue**'u uygulayın. 
 3. Kaynak aşağıdadır, “FireTongueEx” [1]

**2. Bir yerde bir FireTongue örneği oluşturun**

Örneğin, Main'e şu değişken bildirimini ekleyin:

```haxe
public static var tongue:FireTongueEx;
```
Tipinin ```FireTongueEx``` olduğunu, ```FireTongue``` olmadığını unutmayın. (Bu şekilde örnek, ```FlxUI```'nin ihtiyaç duyduğu ```IFireTongue```'yi uygular).

**3. FireTongue örneğini başlatın**

Bu başlatma bloğunu erken kurulum kodunuzun herhangi bir yerine ekleyin (örneğin, ```Main``` veya ilk ```FlxUIState```'inizin ```create()``` bloğuna):

```haxe
if (Main.tongue == null) {
    Main.tongue = new FireTongueEx();
	Main.tongue.init(“en-US”);
    FlxUIState.static_tongue = Main.tongue;
}
```

```FlxUIState.static_tongue``` ayarını yaparsanız, her ```FlxUIState``` örneği ek bir kurulum yapmaya gerek kalmadan otomatik olarak bu ```FireTongue``` örneğini kullanır. Statik referans kullanmak istemiyorsanız, bunu durum bazında yapabilirsiniz:

```haxe
//Bazı FlxUIState nesnelerinin create() işlevinde:
_tongue = someFireTongueInstance;    
```

**4. FireTongue bayraklarını kullanmaya başlayın**

Bir ```FlxUIState``` bir ```FireTongue``` örneğine bağlandığında, herhangi bir ham metin bilgisini sanki bir ```FireTongue``` bayrağıymış gibi otomatik olarak çevirmeye çalışacaktır -- bkz. ```FireTongue```'un [belgeleri](https://github.com/larsiusprime/firetongue).

Aşağıda, “Geri” kelimesinin yerelleştirme bayrağı “$MISC_BACK” aracılığıyla çevrildiği bir örnek verilmiştir:
```haxe
<button center_x="true" x="0" y="535" name="start" label="$MISC_BACK">        
    <param type="string" value="back"/>
</button>
```
İngilizce'de (en-US) bu “Back” olacak, Norveççe'de (nb-NO) ise “Tilbake” olacaktır....



[1] İşte ```FireTongueEx.hx``` için kaynak kodu parçacığı:
```haxe
import firetongue.FireTongue;
import flixel.addons.ui.interfaces.IFireTongue;

/**
 * Bu, bir ikilemi çözmek için basit bir sarmalayıcı sınıftır:
 * 
 * flixel-ui'nin firetongue'a bağımlı olmasını istemiyorum.
 * firetongue'un flixel-ui'ye bağımlı olmasını istemiyorum.
 * 
 * Bunu flixel-ui'de IFireTongue arayüzünü kullanarak çözebilirim.
 * Ancak, bu arayüz bir isim alanına veya diğerine girmeli ve eğer onu
 * firetongue'a koyarsam, bir bağımlılık oluşur. Ve tersi de geçerlidir.
 * 
 * Bu, her iki kütüphaneyi de içeren gerçek proje
 * kodunda basit bir sarmalayıcı sınıf oluşturarak çözülür. 
 * 
 * Sarmalayıcı, FireTongue'u genişletir ve IFireTongue'u uygular.
 * 
 * Gerçek genişletilmiş sınıf hiçbir şey yapmaz, sadece FireTongue'a geçer.
 */
class FireTongueEx extends FireTongue implements IFireTongue
{
    public function new() 
    {
        super();
    }    
}
````

----------

# Gelişmiş İpuçları ve Püf Noktaları

Ne yaptığınızı bir kez öğrendikten sonra, flixel-ui ile yapabileceğiniz birçok akıllı şey vardır.

## 1. “screen” widget'ı her zaman flixel tuvalini temsil eder.

Herhangi bir kök düzey FlxUI nesnesinde, sistem tarafından “screen” adıyla ayrılmış bir FlxUIRegion her zaman tanımlanmıştır. Böylece, formüllerinizde her zaman “screen.width”, “screen.top”, “screen.right” vb. kullanabilirsiniz.

## 2. Çözünürlükten bağımsız metin

Yeni başlayanlar genellikle yazı tiplerini şu şekilde mutlak terimlerle tanımlar:
```xml
<definition name="sans10" font="verdana" size="10" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans12" font="verdana" size="12" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans12" font="verdana" size="16" style="bold" color="0xffffff" outline="0x000000"/>
<tanım adı="sans12" yazı tipi="verdana" boyut="20" stil="kalın" renk="0xffffff" dış çizgi="0x000000"/>
<tanım adı="sans12" yazı tipi="verdana" boyut="30" stil="kalın" renk="0xffffff" dış çizgi="0x000000"/>
```

Oyununuz 800x600 çözünürlükteyse 10 punto yazı tipi gayet iyi görünebilir, ancak kullanıcıya pencere/ekran boyutunu seçme imkanı verirseniz ve kullanıcı oyunu 1920x1080 çözünürlükte görüntülerse ne olur? Ya birden fazla farklı cihazı hedefliyorsanız? 800x600 çözünürlükte, 10 punto yazı tipi toplam ekran yüksekliğinin %1,67'sini kaplar. 1920x1080 çözünürlükte ise %0,93'ünü kaplar, yani neredeyse yarısı kadar! Bu yüzden daha büyük bir yazı tipi kullanmalıyız. Ancak her metin alanını incelemek ve güncellemek için kod kullanmak çok zahmetli olabilir. İşte daha iyi bir yöntem:

```xml
<definition name="sans_tiny"     font="verdana" size="screen.height*0.01667" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans_small"    font="verdana" size="screen.height*0.02000" style="bold" color="0xffffff" outline="0x000000"/>
<tanım adı="sans_medium"   yazı tipi="verdana" boyut="ekran yüksekliği*0,02667" stil="kalın" renk="0xffffff" dış çizgi="0x000000"/>
<tanım adı="sans_large"    yazı tipi="verdana" boyut="ekran yüksekliği*0.03334" stil="kalın" renk="0xffffff" dış çizgi="0x000000"/>
<tanım adı="sans_huge"     yazı tipi="verdana" boyut="ekran yüksekliği*0,04167" stil="kalın" renk="0xffffff" dış çizgi="0x000000"/>
<definition name="sans_enormous" font="verdana" size="screen.height*0.05000" style="bold" color="0xffffff" outline="0x000000"/>
```

Yazı tipi boyutunu ekran yüksekliği cinsinden tanımlayarak, 800x600 çözünürlükte aynı sonuçları elde edebiliriz, ancak metni ekranın boyutuna göre dinamik olarak büyütürüz. “sans_tiny” 800x600 çözünürlükte 10 punto yüksekliğinde olacak, ancak 1920x1080 çözünürlükte 18 punto yüksekliğinde olacak ve ekranın aynı oranını temsil edecektir.

# 3. Koşullu ölçeklendirme

Diyelim ki 16x9 ekran modunda 4x3 modundan farklı bir varlık yüklemek ve bunu ekrana sığdırmak istiyorsunuz.

```xml
<sprite name="thing" src="ui/asset">
	<scale screen_ratio="1.77" tolerance="0.25" suffix="_16x9" width="100%" height="100%"/>
    <scale screen_ratio="1.33" tolerance="0.25" suffix="_4x3" width="100%" height="100%"/>
</sprite>
```

```screen_ratio``` ve ```tolerance``` isteğe bağlıdır -- bunlar, ```<scale>``` düğümünün etkinleştirilip etkinleştirilmeyeceğini filtrelemenizi sağlar. Belirtilmezse, verilen <scale> düğümü hemen uygulanır. Oran genişlik/yüksekliktir ve tolerans, hareket alanıdır.

```suffix```, src parametrenize uygulanacak son ek, “ui/asset”tir. ```width```/```height```, elbette, Flixel-UI işaretlemesinde olduğu gibi ele alınır.

Yukarıdaki örnekte, ekran 16:9 oranının 0,25 içindeyse “ui/asset_16x9.png” dosyasını yükler, 4:3 oranının 0,25 içindeyse “ui/asset_4x3.png” dosyasını yükler ve her iki durumda da ekranı sığdırmak için ölçeklendirir.

Ancak bazen ```width```/```height``` değerlerini ayrı ayrı ölçeklendirmek istemeyebilirsiniz. En yaygın kullanım örneği, yalnızca dikey eksene göre ölçeklendirme yapmak ve ardından genişliği otomatik olarak orantılı olarak ölçeklendirmektir. Bunun için “to_height” kullanın:

```xml
<sprite name="thing" src="ui/asset">
    <scale screen_ratio="1.77" tolerance="0.25" suffix="_16x9" to_height="100%"/>
	<scale screen_ratio="1.33" tolerance="0.25" suffix="_4x3" to_height="100%"/>
</sprite>
```

Bu `<scale>` etiketlerinin, bir sprite gibi ölçeklendirme sırasında antialiasing özelliğini kapatmak/açmak için “smooth” özniteliğini kabul ettiğini unutmayın.

# 4. 9 dilimli sprite kaynağını ölçeklendirme 9 dilimli ölçeklendirmeden ÖNCE

Diyelim ki 9 dilimli bir sprite'ınız var, ancak herhangi bir nedenle *kaynak* görüntüyü önce ölçeklendirmek istiyorsunuz, *sonra* 9 dilimli matrise tabi tutmak istiyorsunuz. Bunu şu şekilde yapabilirsiniz:

```xml
<chrome name="chrome" width="600" height="50" src="ui/asset" slice9="4,4,395,95">
    <scale_src to_height="10%"/>
    <anchor y="bottom" y-flush=“bottom”/>
</chrome>
```

İşte olanlar. Diyelim ki “ui/asset.png” 400x50 piksel. Bu durumda, önce 9 dilimli sprite'lara özgü ```<scale_src>``` etiketini kullanarak küçültüyorum. “to_height” özelliği, varlığı hedef yüksekliğe (bu durumda ekran yüksekliğinin %10'u) ölçeklendirir ve genişliği de orantılı olarak ölçeklendirir. (Bunun yerine “width” ve “height” parametrelerini de kullanabilirsiniz). 9-slice sprite'ta bir varlığı bu şekilde ölçeklediğinizde, slice9 koordinatları otomatik olarak yeni ölçeklenmiş kaynak malzemeye uyacak şekilde ölçeklenir. Ardından, nihai varlığınız 9-slice ölçeklenir.

# 5. “Noktalar” tanımlama

Daha önce şuna sahiptik:

```xml
<definition name="sans10" font="verdana" size="10" style="bold" color="0xffffff" outline="0x000000"/>
```

Bunu şuna değiştirdik:

```xml
<definition name="sans_tiny"     font="verdana" size="screen.height*0.01667" style="bold" color="0xffffff" outline="0x000000"/>
```

Artık bunu yapabilirsiniz!
```xml
<point_size x="screen.height*0.001667" y="screen.width*0.001667"/>
<definition name="sans10" font="verdana" size="10pt" style="bold" color="0xffffff" outline="0x000000"/>
```

```<point_size/>``` etiketini kullandığınızda, sayısal bir değer girip sonuna “pt” harflerini eklediğinizde referans alınan “nokta”nın yatay ve dikey boyutunu tanımlamış olursunuz. Temel olarak, “10pt” gördüğünde, 10'u noktanın boyutuyla çarpar. Yazı tipi boyutları için bu, noktanın dikey boyutudur, diğer yerlerde ise bağlamdan çıkarılır (x=“15pt” yatay pt boyutu, y="25pt" dikey pt boyutudur).

Bunu yaparsanız:
```xml
<point_size value="screen.height*0.001667"/>
```
Dikey ve yatay nokta boyutu için aynı değeri kullanır. Merak ediyorsanız, 0.001667, 1/600 değeridir. Yani, temel düzeni 800x600 olarak yaptığınız bir oyununuz varsa, bu nokta değerini tanımlayarak diğer çözünürlüklere kolayca ölçeklendirebilirsiniz.

Aynı anda yalnızca bir ```<point_size/>``` etiketi etkindir, bu da belgede ayrıştırma işlemi sırasında bulunan son etikettir. Ancak, bir etiketi dahil edilen dosyaya ekleyebilirsiniz ve bu etiket yüklenecektir (mevcut dosyanızda bunu geçersiz kılan bir etiket bulunmadığı sürece).

Normal sayısal değerleri kullanabileceğiniz her yerde (en azından bence) nokta sayısını da kullanabilirsiniz.
