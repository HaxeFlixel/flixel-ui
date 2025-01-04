![](https://raw.github.com/HaxeFlixel/haxeflixel.com/master/src/files/images/flixel-logos/flixel-ui.png)

[flixel](https://github.com/HaxeFlixel/flixel) | [eklentiler](https://github.com/HaxeFlixel/flixel-addons) | [ui](https://github.com/HaxeFlixel/flixel-ui) | [demolar](https://github.com/HaxeFlixel/flixel-demos) | [tools](https://github.com/HaxeFlixel/flixel-tools) | [templates](https://github.com/HaxeFlixel/flixel-templates) | [docs](https://github.com/HaxeFlixel/flixel-docs) | [haxeflixel.com](https://github.com/HaxeFlixel/haxeflixel.com)

[![CI](https://img.shields.io/github/actions/workflow/status/HaxeFlixel/flixel-ui/main.yml?branch=dev&logo=github)](https://github.com/HaxeFlixel/flixel-ui/actions?query=workflow%3ACI)
[![Discord](https://img.shields.io/discord/162395145352904705.svg?logo=discord)](https://discordapp.com/invite/rqEBAgF)
[![Haxelib Sürümü](https://badgen.net/haxelib/v/flixel-ui)](https://lib.haxe.org/p/flixel-ui)
[![Haxelib İndirmeleri](https://badgen.net/haxelib/d/flixel-ui?color=blue)](https://lib.haxe.org/p/flixel-ui)
[![Haxelib Lisansı](https://badgen.net/haxelib/license/flixel-ui)](LICENSE.md)
[![Patreon](https://img.shields.io/badge/donate-patreon-blue.svg)](https://www.patreon.com/haxeflixel)

----

# Hakkında

[HaxeFlixel](https://github.com/HaxeFlixel/flixel)'de UI bileşenlerini oluşturmaya ve UI etkinliklerini yönetmeye yarayan bir dizi araç. 

# Başlarken

## flixel-ui'ı kur:
haxelib'den en son kararlı sürümünü indirin:

    haxelib install flixel-ui

haxelib'den en son bıçak kenarı geliştirici sürümünü indirin:

    haxelib install flixel-ui

Unutmayın ki, flixel-demoları'ndaki test projesi, şöyle kurulabilecek yerelleştirme kütüphanesi **[fireTongue](https://github.com/larsiusprime/firetongue)**'ı gerektirir:

    haxelib install firetongue

Veya github'dan en son geliştirme sürümü için şöyle:

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
Bu, ```<sprite>``, ```<button>``, ```<checkbox>``, vb. gibi birçok Flixel-UI widget'ından herhangi biridir. Aşağıda her biri hakkında daha fazla ayrıntıya gireceğiz, ancak tüm widget etiketlerinin birkaç ortak noktası vardır:

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
* **\<anchor>** - optional, lets you position this widget relative to another object's position.*
* **\<param>** - optional, lets you specify parameters**
* **\<tooltip>** - optional, lets you specify a tooltip.***
* **size tags** - optional, lets you dynamically size a widget according to some formula.*
* **\<locale name=“xx-YY”>** - optional, lets you specify a locale (like “en-US” or “nb-NO”) for [fireTongue](https://github.com/larsiusprime/firetongue) integration. This lets you specify changes based on the current locale:
Example:

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
Cana FlxUI'nizin içinde bir alt FlxUI nesnesi oluşturur ve içindeki tüm widget'ları ona child eder. Bu, özellikle farklı cihazlar ve ekran boyutları için birden fazla düzen oluşturmak istiyorsanız kullanışlıdır. Bu, **failure** etiketleriyle birlikte, ekran boyutuna bağlı olarak en iyi düzeni otomatik olarak hesaplamanıza olanak tanır.

Bir layout'un yalnızca bir niteliği, adı ve ardından alt düğümleri vardır. Bir \<layout>'u xml dosyanızın kendi alt bölümü olarak düşünün. Tam teşekküllü bir FlxUI olduğu için normal dosyaya koyabileceğiniz her şeyin kendi sürümlerine sahip olabilir - yani, tanımlar, gruplar, widget'lar, modlar, hatta muhtemelen diğer düzen etiketleri (bunu test etmedim). 

Bir düzende, kimliklere başvururken kapsamın devreye girdiğini unutmayın. Tanımlar ve nesne referansları ilk olarak düzenin kapsamına (yani, o FlxUI nesnesine) bakacak ve hiçbiri bulunamazsa, bunları üst FlxUI'de bulmaya çalışacaktır. 

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
* karşılaştırma - ```<```,```>```,```<=```,```>=```,```=```,```==`` (```=``` ve ```==`` bu bağlamda eş anlamlıdır)

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

* **text** -- Widget'ın ```text`` özelliğini değiştirin (FlxUIText veya FlxUIInputText). Metin ve/veya etiket içeren nesneler için “bağlam” ve “kod” niteliklerini de ayarlayabilir. \*
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
* ```<graphic>`` - grafik kaynağı (ayrıntılar aşağıda)

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
Tüm özellikleri burada belirtebilir veya bir tanım kullanabilirsiniz. Bir düğmenin içindeki ```<text>`` düğümleri için birkaç özel husus vardır.

Ana “color” özelliği (onaltılık biçim, “0xffffff”) ana etiket rengidir

Diğer durumlar için renk belirtmek isterseniz, her durum için ```<text>`` etiketinin içine ``<color>`` etiketlerini eklersiniz:

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

Geçiş düğmeleri normal bir düğmeden daha fazla grafiğe ihtiyaç duyar. Bunu yapmak için, hem normal hem de değiştirilmemiş durumlar için grafik etiketleri sağlamanız gerekir. Geçişli ```<graphic>`` etiketleri aynıdır, sadece ek bir toggle=“true” niteliğine ihtiyaç duyarlar:

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
* ```check_src``` - source image for check mark (not 9-sliceable, not scaleable)
* ```box_src``` - source image for box (not 9-sliceable, not scaleable)
* ```text_x``` / ```text_y``` - label offsets
* ```label``` - text to show
* ```context``` - FireTongue context (see Button)
* ```code``` - Formatting code (see Button)
* ```checked``` - (boolean) is it checked or not?
* ```label_width``` - width of the label

Child tags:
* ```<text>``` - ```<button>``` ile aynı
* ```<param>``` - ```<button>``` ile aynı
* ```<check>``` - check_src'ye alternatif, daha güçlü*
* ```<box>``` - box_src'ye alternatif, daha güçlü*
  
*Öznitelik eşdeğerleri yerine ``<check>`` veya ``<box>`` alt etiketlerini sağlarsanız, FlxUI bunları onay işareti ve kutu varlıkları için yüklenecek tam teşekküllü ``<sprite>` veya ``<chrome>` etiketleri olarak değerlendirecektir. Normalde statik bir görüntüyü olduğu gibi yükleyen src nitelikleriyle gerçekleştiremeyeceğiniz ölçeklendirilmiş bir sprite veya 9 dilimli ölçeklendirilmiş bir sprite yüklemek gibi karmaşık bir şey yapmak istiyorsanız bu yöntemi kullanmak isteyeceksiniz.

Olay:
* isim - “click_check_box”
* params - kullanıcı tarafından tanımlandığı gibi, ancak bu otomatik olarak listenin sonuna eklenir: ``{name: “checked”, value:false}`` veya ``{name: “checked”, value:true}``

## 7. Text (FlxUIText) ```<text>```

Normal bir metin alanı. 

Nitelikler:
* ```text``` - the actual text in the textfield
* ```x```/```y```, ```use_def```, ```group```
* ```font``` - string, something like "vera" or "verdana"
* ```size``` - integer, size of font
* ```style``` - string, "regular", "bold", "italic", or "bold-italic"
* ```color``` - hex string, ie, "0xffffff" is white
* ```align``` - "left", "center", or "right". Haven't tested "justify"
* ```context``` - FireTongue context (see Button)
* ```code``` - Formatting code (see Button)

Text fields can also have borders. You can do this by specifying these four values:

* ```border``` - string, border style:
  * ```false```/```none``` - no border
  * ```shadow``` - drop shadow
  * ```outline``` - border (higher quality)
  * ```outline_fast``` - border (lower quality)
* ```border_color``` - color of the border
* ```border_size``` - thickness in pixels
* ```border_quality``` - number between 0.0 (lowest) and 1.0 (highest)

You can also use a shortcut for border value to save space by just using "shadow", "outline", or "outline_fast" directly as attributes and assigning them a color.

```xml
<text name="my_text" text="My Text" outline="0xFF0000"/>
```

As for fonts, FlxUI will look for a font file in your ```assets/fonts/``` directory, formatted like this:

|Filename|Family|Style|
|---|---|---|
vera.ttf|Vera|Regular
verab.ttf|Vera|Bold
verai.ttf|Vera|Italic
veraz.ttf|Vera|Bold-Italic

So far just .ttf fonts are supported, and you MUST name them according to this scheme (for now at least).

FlxUI does not yet support FlxBitmapFonts, but we'll be adding it eventually.

### 8. Text, input (FlxUIInputText) ```<input_text>```

This has not been thoroughly tested, but it exists.

Attributes:
* ```x```/```y```, ```use_def```, ```group```
* ```font```, ```size```, ```style```, ```color```, ```align```
* (border attributes)
* ```password_mode``` - bool, hides text if true
* ```background``` - (optional, FlxColor) the background color
* ```force_case``` - (string) force text to appear in a specific case
    * "upper" / "upper_case" / "uppercase"
    * "lower" / "lower_case" / "lowercase"
* ```filter``` - (string) allow only certain kinds of text (not thoroughly tested with non-english locales)
    * "alpha" / "onlyalpha" - only standard alphabet characters
    * "num" / "numeric" - only standard number characters
    * "alphanum" / "alphanumeric", "onlyalphanumeric" -- only standard alphabet & number characters
* ```context``` - FireTongue context (see Button)
* ```code``` - Formatting code (see Button)

## 9. Radio button group (FlxUIRadioGroup) ```<radio_group>```

Radio groups are a set of buttons where only one can be clicked at a time. We implement these as a ```FlxUIGroup``` of ```FlxUICheckBox```'es, and then internal logic makes only one clickable at a time. 

Attributes:
* ```x```/```y```, ```use_def```, ```group```
* ```radio_src``` - image src for radio button back (ie, checkbox "box")
* ```dot_src``` - image src for radio dot (ie, checkbox "check mark")

You construct a radio group by providing as many ```<radio>``` child tags as you want radio buttons. Give each of them an name and a label.

Child Nodes:
* ```<param>``` - same as ```<button>```, 
* ```<radio>``` - two attributes, name (string) and label (string)
* ```<dot>``` - alternate to dot_src, more powerful*
* ```<box>``` - alternate to radio_src, more powerful*

*If you supply ```<dot>``` or ```<box>``` child tags instead of their attribute equivalents, FlxUI will treat them as full-fledged ```<sprite>``` or ```<chrome>``` tags to load for the dot and radio-box assets. You'll want to use this method if you want to do something complicated, like load a scaled sprite, or a 9-slice-scaled sprite, that you can't normally accomplish with the src attributes, which just load a static image as-is.

Event:
* ```name``` - "click_radio_group"
* ```params``` - same as Button

## 10. Tabbed menu (FlxUITabMenu) ```<tab_menu>```

Tab menus are the most complex ```FlxUI``` widget. ```FlxUITabMenu``` extends ```FlxUI``` and is thus a full-fledged ```FlxUI``` in and of itself, just like the ```<layout>``` tag.

This provides a menu with various tabbed buttons on top. When you click on one tab, it will show the content for that tab and hide the rest. 

Attributes:
* ```x```/```y```, ```use_def```, ```group```
* ```width```/```height```
* ```back_def``` - name for a 9-slice chrome definition (MUST be 9-sliceable!)
* ```slice9```

Child Nodes:
* ```<tab>``` - attributes are "name" and "label", much like in ```<radio_group>```
* ```<group>``` - attributes are only "name"
 * Put regular FlxUI content tags here, within the ```<group></group>``` node.

## 11. Line (FlxUISprite) ```<line>```

TODO

## 12. NumStepper (FlxUINumericStepper) ```<numeric_stepper>```

TODO

## 13. Dropdown/Pulldown (FlxUIDropDownMenu) ```<dropdown>```

TODO

## 14. Bar ([FlxUIBar](https://api.haxeflixel.com/flixel/addons/ui/FlxUIBar.html)) ```<bar>```

Provides a Bar that can be used for displaying health or progress.

Attributes:
* ```x```/```y``` - position of the bar
* ```width```/```height``` - dimensions of the bar
* ```fill_direction``` - the fill direction. `left_to_right` is the default. See below for a list of possible values.
* ```parent_ref``` - A reference to an object in your game that you wish the bar to track (the value of)
* ```variable``` - The variable of the object that is used to determine the bar position. For example if the parent was an FlxSprite this could be "health" to track the health value
* ```min``` - The minimum value. I.e. for a progress bar this would be zero (nothing loaded yet)
* ```max``` - The maximum value the bar can reach. I.e. for a progress bar this would typically be 100.
* ```value``` - The value that the bar is at initially. Default is `max`
* ```border_color``` - Color of the border. If omitted there is no border at all.
* ```filled_color``` or ```color``` - The color of the bar when full in hexformat. Default is red.
* ```empty_color``` - The color of the bar when empty in hexformat. Default is red.
* ```filled_colors``` or ```colors``` and ```empty_colors``` - Creates a gradient filled health bar using the given colour ranges.
* ```chunk_size``` - If you want a more old-skool looking chunky gradient, increase this value!
* ```rotation``` - Angle of the gradient in degrees. 90 = top to bottom, 180 = left to right. Any angle is valid
* ```src_filled```/```src_empty``` - Use an image for the filled/empty bar.

Possible `fill_direction` values:
* "left_to_right"
* "right_to_left"
* "top_to_bottom"
* "bottom_to_top"
* "horizontal_inside_out"
* "horizontal_outside_in"
* "vertical_inside_out"
* "vertical_outside_in"


## 15. TileTest (FlxUITileTest) ```<tile_test>```

TODO

## 16. Custom Widget (Any Class which implements IFlxUIWidget) ```<whatever_you_want>```

You can also add a handler to render a custom widget when you add certain tags to your UI. You can specify whichever tags you want, as long as you have a class which implements IFlxUIWidget that you can use to render it.
	
Any widget in the layout whose name does not match those provided by default will be referred to the FlxUI class; simply override `getRequest(name:String, sender:Dynamic, data:Dynamic):Dynamic`, look for a request of the name `ui_get:whatever_you_want`, and return your custom widget.
	
Here is an example. You can see that any instance of `<save_slot>` in the XML will be populated with a SaveSlot widget.
	
```
public override function getRequest(id:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic
{
    if (id.indexOf("ui_get:") == 0)
    {
        switch (id.remove("ui_get:"))
        {
            case "save_slot":
                return new SaveSlot(data, _ui);
        }
    }
    return null;
}
```	

----

# Tooltips

Tooltips can be added to button and button-like widgets, including ```<button>```, ```<button_toggle>```, ```<checkbox>```, the ```<radio>``` child tags of a ```FlxUIRadioGroup```, and the ```<tab>``` child tags of a ```FlxUITabMenu```.

(Note that there is a full-featured "Tooltips" demo in [flixel-demos](https://github.com/haxeflixel/flixel-demos), underneath the "User Interface" category.)

Attributes:
* ```x```/```y``` - x/y offset for the tooltip's anchor
* ```use_def``` - you can specify a definition for a tooltip just like anything else
* ```width```/```height```
* ```text``` - string, set this if you only want one text field, not two (a title and a body text)
* ```background``` - the color of the background
* ```border``` - the size of the outline border, in pixels
* ```border_color``` - the color of the outline border
* ```arrow``` - string, sprite asset source for the arrow
* ```auto_size_horizontal``` - bool, whether to crop the width of the tooltip to bounds of the visible text + padding (default true)
* ```auto_size_vertical``` - bool, whether to crop the height of the tooltip to bounds of the visible text + padding (default true)
* ```pad_left``` - left-side padding, in pixels
* ```pad_right``` - right-side padding, in pixels
* ```pad_top``` - top-side padding, in pixels
* ```pad_bottom``` - bottom-side padding, in pixels
* ```pad_all``` - shortcut, set all 4 padding values in one attribute
 
Child Nodes:
* ```title``` - a FlxUIText node, specifies the title text content and sty
  * ```x```/```y``` - you can specify an x/y offset for the title text itself
  * if you specified the tooltip text via the "text" shortcut attribute, it uses the "title" textfield and hides the body
  * in this case you can still set a style via the "title" node
* ```body``` - a FlxUIText node, specifies the body text content and style
  * ```x```/```y``` - you can specify an x/y offset for the body text itself
  * note that the default position of the ```body``` text field is directly underneath the title textfield
* ```anchor``` - this specifies how your tooltip attaches to its parent object. 
  * You do this the same way you would use anchor tags elsewhere, with ```x```/```y``` and ```x-flush```/```y-flush```. 
  * Note that the ```x```/```y``` *attributes* set in the ```<tooltip>``` node itself serve as the x/y *offsets* for the anchor, just as they do with every other widget.

A very basic tooltip is added like this:

```xml
<button name="basic" x="160" y="120" label="Basic">
    <tooltip text="Basic tooltip"/>
</button>
```

This tooltip uses both text fields:

```xml
<button name="fancier" x="basic.x" y="basic.bottom+10" label="Fancier">
	<tooltip>
		<title text="Fancier tooltip!" width="100"/>
		<body text="This tooltip has a title AND a body." width="100" />
	</tooltip>
</button>
```

This tooltip sets just about everything:

```xml
<button name="fanciest" x="basic.x" y="even_fancier.bottom+10" label="Fanciest">
	<tooltip pad_all="5" background="red" border="1" border_color="white">
		<title use_def="sans12" text="Fanciest tooltip!" width="125"/>
		<body use_def="sans10" text="This tooltip has a title and a body, custom padding and offsets, as well as custom text formatting" width="120" x="5" y="5"/>
		<anchor x="center" x-flush="center" y="bottom" y-flush="top"/>
	</tooltip>
</button>
```

----

# Dynamic position & size

## 1. Anchor Tags

Here's an example of a health bar from an RPG:

```xml
<nineslicesprite name="health_bar" x="10" y="5" width="134" height="16" use_def="health">
	<anchor x="portrait.right" y="portrait.top" x-flush="left" y-flush="top"/>
</nineslicesprite>
```

There is presumably another sprite defined somewhere called "portrait" and we want our health bar to show up relative to wherever that is. 

The anchor's x and y specify a specific point, and x-flush and y-flush specify which corner of the object should be aligned to that point. The main object's x / y will be added on as offsets after the object is flushed to the anchor.

Acceptable values for x/y:
* "left", "right", "top", or "bottom": edges of the flixel canvas.
* object properties (ie, "some_id.some_property"):
 * "left", "right", "top", "bottom": edges of that object
 * "center": center of that object (axis inferred from x or y attribute)

Acceptable values for x-flush/y-flush:
* "left"
* "right"
* "top"
* "bottom"
* "center"

You can also specify a **round** attribute (up/down/round/true/false) in the anchor tag itself to round the final calculated position.

**Note to non-native speakers of English:** "flush" is a carpentry term, so if one side of one object is parallel to and touching another object's side with no air between them, the objects are "flush." This has nothing to do with toilets :)

--
## 2. Position Tags

Sometimes you want to be able to change the position of a widget later in the xml markup. Position tags work much like the original creation tag for the object, except you ONLY include the attribute name of the object you want to move, and any relevant position information.

```xml
<position name="thing" x="12" y="240"/>
```

You can use anchor tags, formulas, etc inside a position tag:
```xml
<position name="thing" x="other_thing.right" y="other_thing.bottom">
  <anchor name="other_thing" x-flush="left" y-flush="top"/>
</position>
```

--
## 3. Size Tags

Let's add a size tag to our health bar:
```xml
<nineslicesprite name="health_bar" x="10" y="5" width="134" height="16" use_def="health" group="mcguffin">
	<anchor x="portrait.right" y="portrait.top" x-flush="left" y-flush="top"/>
	<exact_size width="stretch:portrait.right+10,right-10"/>
</nineslicesprite>
```

There are three size tags: ```<min_size>```, ```<max_size>```, and ```<exact_size>```

This lets you either specify dynamic lower/upper bounds for an object's size, or force it to be an exact size. This lets you create a UI that can work in multiple resolutions, or just avoid having to do manual pixel calculations yourself. 

Size tags take only three attributes, **width**, **height**, and **round**. If either width or height is not specified, that part of the size is ignored and remains the same size.

There are several ways to formulate a width/height attribute:

* **number** (ie, width="100")
* **stretch** (ie, width="stretch:some_value,another_value")
* **reference** (ie, width="some_id.some_value")

A **stretch** formula will tell FlxUI to calculate the difference between two values separated by a comma. These values are formatted and calculated just like a **reference** formula. The axis is inferred from whether it's width or height. 

So, if you have a scoreboard at the top of the screen, and you want the playfield to stretch from the bottom of the scoreboard to the bottom of the screen:

```xml
<exact_size height="stretch:scoreboard.bottom,bottom"/>
```

Acceptable property values for reference formula, used alone or in a stretch:
* **naked reference** (ie, "some_id") - returns inferred x or y position of that thing.
* **property reference** (ie, "some_id.some_value") - returns a thing's property
 * "left", "right", "top", "bottom", "width", "height", "halfwidth", "halfheight", "centerx", "centery"
 * "center" (infers centerx or centery)
* **arithmetic formula** (ie, "some_id.some_value+10") - do some math
 * You can tack on **one** operator and **one** operand (numeric value or widget property) to any of the above.
 * Legal operators = (+, -, *, \, ^)
 * Don't try to get too crazy here. If you need to do some super duper math, just add some code in your FlxUIState, call getAsset("some_id") to grab your assets, and do the craziness yourself.

--
## 4. Alignment Tags

An ```<align>``` tag lets you automatically align and space various objects together.

```xml
<align axis="horizontal" spacing="2" resize="true">
	<bounds left="options.left" right="options.right"/>
	<objects value="spell_0,spell_1,spell_2,spell_3,spell_4,spell_5"/>
</align>
```

Attributes:
* axis - "horizontal" or "vertical"
* spacing - number
* resize - bool, optional, "true" or "false" (if not exist, assumes false)

Child tags:
* ```<bounds>``` - string, reference formula, specify left & right for horizontal, or top & bottom for vertical
* ```<objects>``` - string, comma separated list of object name's

If you specify more than one "objects" tag, you can align several groups of objects at once according to the same rules. For instance, if you have obj_0 through obj_9 (10 in total), and you want two rows spaced evenly in five columns, this would do the trick:

```xml
<align axis="horizontal" spacing="2" resize="true">
	<bounds left="options.left" right="options.right"/>
	<objects value="obj_0,obj_1,obj_2,obj_3,obj_4"/>
	<objects value="obj_5,obj_6,obj_7,obj_8,obj_9"/>
</align>
```

Whereas putting all 10 objects in one ```<objects>``` tag would instead get you one row with 10 columns.

----

# Localization (FireTongue)
First, Firetongue has some [documentation](https://github.com/larsiusprime/firetongue) on its Github page. Read that. 

In your local project, follow these steps:

**1. Create a FireTongue wrapper class**

 It just needs to:
 1. Extend **firetongue.FireTongue**
 2. Implement **flixel.addons.ui.IFireTongue** 
 3. Source is below, "FireTongueEx" [1]

**2. Create a FireTongue instance somewhere**

Add this variable declaration in Main, for instance:

```haxe
public static var tongue:FireTongueEx;
```
Note that it's type is ```FireTongueEx```, not ```FireTongue```. (This way the instance implements ```IFireTongue```, which ```FlxUI``` needs).

**3. Initialize your FireTongue instance**

Add this initialization block anywhere in your early setup code (either in ```Main``` or in the ```create()``` block of your first ```FlxUIState```, for instance):

```haxe
if (Main.tongue == null) {
	Main.tongue = new FireTongueEx();
	Main.tongue.init("en-US");
	FlxUIState.static_tongue = Main.tongue;
}
```

Setting ```FlxUIState.static_tongue``` will make every ```FlxUIState``` instance automatically use this ```FireTongue``` instance without any additional setup. If you don't want to use a static reference, you can just do this on a per-state basis:

```haxe
//In the create() function of some FlxUIState object:
_tongue = someFireTongueInstance;	
```

**4. Start using FireTongue flags**

Once a ```FlxUIState``` is hooked up to a ```FireTongue``` instance, it will automatically attempt to translate any raw text information as if it were a ```FireTongue``` flag -- see ```FireTongue```'s [documentation](https://github.com/larsiusprime/firetongue).

Here's an example, where the word "Back" is translated via the localization flag "$MISC_BACK":
```haxe
<button center_x="true" x="0" y="535" name="start" label="$MISC_BACK">		
	<param type="string" value="back"/>
</button>
```
In English (en-US) this will be "Back," in Norwegian (nb-NO) this will be "Tilbake."

...

[1] Here's the source code snippet for ```FireTongueEx.hx```:
```haxe
import firetongue.FireTongue;
import flixel.addons.ui.interfaces.IFireTongue;

/**
 * This is a simple wrapper class to solve a dilemma:
 * 
 * I don't want flixel-ui to depend on firetongue
 * I don't want firetongue to depend on flixel-ui
 * 
 * I can solve this by using an interface, IFireTongue, in flixel-ui
 * However, that interface has to go in one namespace or the other and if I put
 * it in firetongue, then there's a dependency. And vice-versa.
 * 
 * This is solved by making a simple wrapper class in the actual project
 * code that includes both libraries. 
 * 
 * The wrapper extends FireTongue, and implements IFireTongue
 * 
 * The actual extended class does nothing, it just falls through to FireTongue.
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

# Advanced Tip & Tricks

There's a lot of clever things you can do with flixel-ui once you know what you're doing.

## 1. "screen" widget always represents the flixel canvas

There is always a FlxUIRegion defined by the system in any root-level FlxUI objects with the reserved named "screen". So you can always use "screen.width", "screen.top", "screen.right", etc, in any of your formulas.

## 2. Resolution independent text

It's common for beginners to define their fonts in absolute terms like this:
```xml
<definition name="sans10" font="verdana" size="10" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans12" font="verdana" size="12" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans12" font="verdana" size="16" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans12" font="verdana" size="20" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans12" font="verdana" size="30" style="bold" color="0xffffff" outline="0x000000"/>
```

Size 10 font might look just fine if your game is 800x600, but what if you let the user choose the window/screen size, and they're viewing the game in 1920x1080? What if you're targetting multiple different devices? At 800x600, Size 10 font is 1.67% of the total screen height. At 1920x1080, it's 0.93%, almost half the size! So we should use a bigger font. But it might be a huge pain to use code to inspect every text field and update it. Here's a better way to do things:

```xml
<definition name="sans_tiny"     font="verdana" size="screen.height*0.01667" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans_small"    font="verdana" size="screen.height*0.02000" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans_medium"   font="verdana" size="screen.height*0.02667" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans_large"    font="verdana" size="screen.height*0.03334" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans_huge"     font="verdana" size="screen.height*0.04167" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans_enormous" font="verdana" size="screen.height*0.05000" style="bold" color="0xffffff" outline="0x000000"/>
```

By defining the font size in terms of the screen height, we can achieve the same results at 800x600, but make the text grow dynamically with the size of the screen. "sans_tiny" will be 10 points high in 800x600, but 18 points high in 1920x1080, representing the same proportion of the screen.

# 3. Conditional scaling

Let's say you want to load a different asset in a 16x9 screen mode than a 4x3 mode, and fit it to the screen.

```xml
<sprite name="thing" src="ui/asset">
	<scale screen_ratio="1.77" tolerance="0.25" suffix="_16x9" width="100%" height="100%"/>
	<scale screen_ratio="1.33" tolerance="0.25" suffix="_4x3" width="100%" height="100%"/>
</sprite>
```

```screen_ratio``` and ```tolerance``` are optional -- they let you filter whether the ```<scale>``` node is activated. If not supplied, the given <scale> node is immediately applied. The ratio is width/height and tolerance is the wiggle room.

```suffix``` is the suffix to apply to your src parameter, "ui/asset". ```width```/```height```, of course, are treated as they are throughout Flixel-UI markup.

So in the above example, if the screen is within 0.25 of a 16:9 ratio, it will load "ui/asset_16x9.png", if it's within 0.25 of a 4:3 ratio, it will load "ui/asset_4x3.png", and in both cases will scale them to fit the screen.

But sometimes you don't want to scale both ```width```/```height``` separately, the most common use case is to scale based on the vertical axis alone and then automatically scale width proportionately. Use "to_height" for this:

```xml
<sprite name="thing" src="ui/asset">
	<scale screen_ratio="1.77" tolerance="0.25" suffix="_16x9" to_height="100%"/>
	<scale screen_ratio="1.33" tolerance="0.25" suffix="_4x3" to_height="100%"/>
</sprite>
```

Note that these `<scale>` tags accept the "smooth" attribute to turn antialiasing off/on when scaling, just like a sprite can.

# 4. Scaling 9-slice-sprite source BEFORE 9-slice-scaling

Let's say you've got a 9-slice-sprite, but for whatever reason you want to scale the *source* image first, *before* you then subject it to the 9-slice matrix. You can do that like this:

```xml
<chrome name="chrome" width="600" height="50" src="ui/asset" slice9="4,4,395,95">
	<scale_src to_height="10%"/>
	<anchor y="bottom" y-flush="bottom"/>
</chrome>
```

Here's what's happening. Let's say "ui/asset.png" is 400x50 pixels. In this case I scale it down first using the ```<scale_src>``` tag, which is unique to 9-slice-sprites. The "to_height" property scales the asset to a target height (10% of the screen height in this case), and also scales the width proportionately. (You can also use "width" and "height" parameters instead). Whenever you scale an asset like this in a 9-slice sprite, the slice9 coordinates will be automatically be scaled to match the new scaled source material. Then, your final asset will be 9-slice scaled.

# 5. Defining "points"

So previously we had this:

```xml
<definition name="sans10" font="verdana" size="10" style="bold" color="0xffffff" outline="0x000000"/>
```

Which we changed to this:

```xml
<definition name="sans_tiny"     font="verdana" size="screen.height*0.01667" style="bold" color="0xffffff" outline="0x000000"/>
```

Now you can just do this!
```xml
<point_size x="screen.height*0.001667" y="screen.width*0.001667"/>
<definition name="sans10" font="verdana" size="10pt" style="bold" color="0xffffff" outline="0x000000"/>
```

Whenever you use the ```<point_size/>``` tag, you are defining the horizontal and vertical size of a "point", which is referenced whenever you enter a numerical value and add the letters "pt" to the end. Basically whenever it sees "10pt" it will multiply 10 by the size of the point. For font sizes this is the vertical size of the point, in other places it infers from the context (x="15pt" is horizontal pt size, y="25pt" is vertical pt size).

If you do this:
```xml
<point_size value="screen.height*0.001667"/>
```
It uses the same value for both vertical and horizontal point size. In case you were wondering, 0.001667 is the value of 1/600. So if you have a game where you do the base layout at say 800x600, then you can define this point value to make it easily scale to other resolutions.

Only one ```<point_size/>``` tag is active at a time, the last one that the parse finds in the document. You can, however, put one in an included file and it will be loaded (so long as your current file doesn't have one that overrides it).

You can use a point-number anywhere (at least, I think) you can use a normal numerical value.
