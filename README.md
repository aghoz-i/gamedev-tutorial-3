Note: Referensi dari Chat-GPT untuk mekanisme-mekanisme teknikal, bukan logic dari program/script (contoh dari Chat-GPT: cara ganti static sprite)
## Latihan mandiri: Eksplorasi Mekanika Pergerakan
Beberapa mekanisme ini diambil dari Dokumen Tutorial-3 dan game `Brawlhalla`
### Double Jump:
Implementasi double jump dilakukan dengan pertama membuat variabel `jump_count` dan variabel `jump_speed`.

```
@export var jump_speed = -300
var jump_count = 0
```
Ketika pemain menekan tombol atas, dan nilai `jump_count` < 2, maka objek `Player` akan diset `velocity.y` menjadi `jump_speed`

```
if jump_count < 2 and Input.is_action_just_pressed('ui_up'):
	jump_count += 1
	velocity.y = jump_speed
```
Selain itu, ditambahkan juga kondisi reset untuk `jump_count`, yaitu ketika objek player menyentuh lantai.
```
if is_on_floor():
	jump_count = 0
```

### Fast-fall
Fast-fall adalah salah satu mekanisme pergerakan di Brawlhalla, dimana ketika pemain menekan tombol bawah ketika di udara, maka `Player` akan jatuh lebih cepat.

Implementasi Fast-fall dilakukan dengan pertama mengeset nilai `fast_fall_modifier`.
```
@export var fast_fall_modifier = 500
```
Ketika tombol bawah ditekan, dan objek `Player` sedang di udara (tidak di lantai), maka `fast_fall_modifier` akan ditambahkan ke `velocity.y`
```
if not is_on_floor() and Input.is_action_just_pressed('ui_down'):
    velocity.y += fast_fall_modifier
```
Kemudian, ketika tombol bawah dilepas, nilai `fast_fall_modifier` akan di substraksi dari `velocity.y`, yang menyebabkan `Player` keluar dari gerakan Fast-fall. 
```
if not is_on_floor() and Input.is_action_just_released('ui_down'):
    velocity.y -= fast_fall_modifier
```

### Dash
Implementasi Dash dilakukan dengan membuat beberapa variabel di awal untuk mengatur aturan teknis Dash, yaitu `dash_speed`, `dash_duration`, `last_left_pressed`, `last_right_pressed`, `dash_timer`, `is_dashing`.
```
@export var dash_speed = 500
@export var dash_duration = 300

var last_left_pressed = -1000   # untuk menyimpan kapan terakhir tombol kiri ditekan
var last_right_pressed = -1000  # untuk menyimpan kapan terakhir tombol kanan ditekan
var dash_timer = 0              # untuk menyimpan sisa waktu dari dash yang sedang berlangsung
var is_dashing = false          # untuk menyimpan state apakah sedang nge-dash
```

Deteksi apakah pemain game hendak melakukan dash. Ini diimplementasikan menggunakan `is_action_just_pressed` dan `Time.get_ticks_msec()`, yang dikombinasikan dengan `last_left_time` atau `last_right_time`.
Pemain dianggap hendak melakukan dash jika dia menekan tombol kanan atau kiri dua kali, dengan maksimal waktu antara kedua tombol ditekan adalah 200ms.
Jika pemain melakukan dash, maka `velocity.x` akan diset `dash_speed`, `dash_timer` akan diset `dash_duration`, dan `is_dashing` akan diset `true`.
Jika pemain tidak sedang melakukan dash, maka waktu tombol kanan/kiri ditekan akan disimpan ke `last_left_pressed` atau `last_right_preswsed`.
```
if Input.is_action_just_pressed("ui_left") and not is_dashing:
    var current_time = Time.get_ticks_msec()
    if current_time - last_left_pressed <= 200:
        velocity.x = -dash_speed
        dash_timer = dash_duration
        is_dashing = true
    else:
        last_left_pressed = Time.get_ticks_msec()
elif Input.is_action_just_pressed("ui_right") and not is_dashing:
    var current_time = Time.get_ticks_msec()
    if current_time - last_right_pressed <= 200:
        velocity.x = dash_speed
        dash_timer = dash_duration
        is_dashing = true
    else:
        last_right_pressed = Time.get_ticks_msec()
```

Kemudian, untuk membedakan objek `Player` sedang dash atau tidak, dan bagaimana menentukan perilaku `Player` ketika dilakukan operasi tertentu, maka dimanfaatkanlah variabel `is_dashing`.
Ketika `is_dashing` bernilai `true`, `velocity.y` diset menjadi 0, yang membuat objek Player tidak akan bergerak relatif di sumbu-y, untuk memberikan impresi bahwa objek `Player` benar-benar nge-dash.
Selain itu, `dash_timer` akan dikurangi seiring dengan waktu.
Sedangkan jika `is_dashing` bernilai `false`, maka objek `Player` akan berjalan biasa dengan kecepatan `walk_speed`.
```
if is_dashing:
    velocity.y = 0
    dash_timer -= delta*1000
elif Input.is_action_pressed("ui_left"):
    velocity.x = -walk_speed
elif Input.is_action_pressed("ui_right"):
    velocity.x = walk_speed
else:
    velocity.x = 0
```
Terakhir, untuk mengembalikan state `Player` dari `is_dashing == true` menjadi `is_dashing == false` ketika dash selesai, ditambahkan kode dibawah.
```
if dash_timer <= 0:
    is_dashing = false
```


## Bonus: Ganti static sprite berdasarkan gerakan
Tambahkan variabel-variabel dibawah untuk mengatur sprite di Script.
```
@onready var sprite = $Sprite2D 

@export var idle_texture: Texture
@export var walk_texture: Texture
@export var dash_texture: Texture
```
Dengan menggunakan `@export var`, tekstur dapat diatur dengan klik Node Player di Scene, dan memilih di Inspector window

Setelah mengeset tekstur, kita bisa menggunakan dan mengubah sprite di script berdasarkan gerakan tertentu. 
Yang sering saya gunakan adalah `sprite.texture` (untuk mengubah tekstur) dan `sprite.flip_h` (untuk mengubah arah kiri/kanan). 
Contoh, untuk jalan ke kiri dan kanan seperti kode di bawah
```
elif Input.is_action_pressed("ui_left"):
    sprite.flip_h = true 
    velocity.x = -walk_speed
elif Input.is_action_pressed("ui_right"):
    sprite.flip_h = false
    velocity.x = walk_speed
```
Contoh lain, untuk sprite dash.
```
if Input.is_action_just_pressed("ui_left") and not is_dashing:
    var current_time = Time.get_ticks_msec()
    if current_time - last_left_pressed <= 200:
        sprite.texture = dash_texture
        sprite.flip_h = true
        velocity.x = -dash_speed
        dash_timer = dash_duration
        is_dashing = true
    else:
        last_left_pressed = Time.get_ticks_msec()
elif Input.is_action_just_pressed("ui_right") and not is_dashing:
    var current_time = Time.get_ticks_msec()
    if current_time - last_right_pressed <= 200:
        sprite.texture = dash_texture
        sprite.flip_h = false
        velocity.x = dash_speed
        dash_timer = dash_duration
        is_dashing = true
    else:
        last_right_pressed = Time.get_ticks_msec()
```
