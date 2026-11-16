# Bento Kopi

Direktori informatif 16 kafe di Jember; tanpa transaksi, keranjang, atau pemesanan.
Stack: HTML/CSS/JS dengan generator Node kecil dipilih agar halaman lengkap tetap statis, ringan, dan dapat disajikan Nginx tanpa server aplikasi.

## Jalankan

Prasyarat: Docker Engine dengan Docker Compose v2. Build pertama perlu internet untuk image Docker dan paket npm; situs yang sudah berjalan tidak meminta aset dari domain luar.

```bash
docker compose up -d --build
```

Buka http://localhost:8080. `docker compose up` juga membangun image otomatis jika belum ada; setelah mengubah data, foto, font, kode, atau konfigurasi build, gunakan kembali `--build`.

```bash
docker compose config
docker compose ps
docker compose logs --tail=50 web
docker compose exec web nginx -t
curl -I http://localhost:8080/
curl -I http://localhost:8080/kafe/kissa-haus-coffee-shop/
curl -I http://localhost:8080/tentang/
curl -I http://localhost:8080/tidak-ada/
```

Tiga halaman pertama harus HTTP 200. URL terakhir harus HTTP 404 dengan halaman “Sepertinya salah belok”, bukan 200. Status health akan menjadi `healthy` setelah pemeriksaan berjalan. Container produksi memakai user `nginx`, filesystem read-only, direktori sementara `/tmp`, dan tidak membutuhkan capability tambahan. Sysctl Compose mengizinkan user tersebut mengikat port 80 di dalam container. Port host tetap 8080.

## Mengubah / menambah kafe

Satu-satunya sumber data kafe adalah `data/cafes.json`; salinan awalnya identik dengan lampiran. Tambah objek ke array menggunakan bentuk field yang sudah ada, dengan `slug` unik berhuruf kecil dan tanda hubung. Isi hanya fakta yang diketahui; tetap gunakan `null` atau array kosong untuk data yang belum tersedia. `tautan_lain` boleh tidak ada atau `null`.

- `kisaran_harga` hanya `Rp` atau `RpRp`; kategori kasar, bukan nominal atau batas harga.
- `harga` menu berupa angka rupiah ketika sudah diketahui. `null` tidak menampilkan harga.
- `status_data` yang mengandung `draf` menghasilkan badge “Info belum diverifikasi”.
- `terakhir_diperbarui` memakai `YYYY-MM-DD`.
- Area filter diambil otomatis dari data. Kamus label tag ada di `src/shared.js`.
- Kontak yang kosong tidak menghasilkan tautan. Koordinat tidak perlu diisi jika belum diketahui.

Setelah edit:

```bash
docker compose up -d --build
```

Filter menggabungkan nama/area/tag yang dicari, area, suasana, satu fasilitas, kategori harga, dan buka sekarang. Kondisi antarkolom memakai AND. Filter tersimpan di query URL sehingga dapat dibagikan. Reset menghapus semua filter. Semua kartu dan detail tetap tersedia tanpa JavaScript.

## Jam buka

Perhitungan memakai `Asia/Jakarta` (WIB), bukan zona waktu perangkat pengunjung. Parser mendukung semua format dalam data awal: `Buka 24 jam`, `Setiap hari HH:MM-HH:MM`, kelompok/rentang hari dengan koma atau `&`, pemisah `;`, dan pengecualian `(Kamis buka 07:00)`. Nama hari lengkap dan singkatan Indonesia didukung.

Jam lewat tengah malam diperhitungkan dari hari sebelumnya; batas tutup eksklusif. Jika ada jadwal yang tidak dikenali, filter “buka sekarang” disembunyikan untuk seluruh direktori agar tidak mengecualikan tempat secara keliru. Teks jadwal asli tetap tampil; status detail hanya muncul untuk jadwal yang dikenali. Informasi buka ini bukan konfirmasi operasional langsung.

## Menambah foto

Simpan file asli di `public/images/<slug>/`. Format yang diterima: JPG/JPEG, PNG, WebP, AVIF. Tidak ada unduhan atau hotlink gambar. Gunakan foto dengan izin pemiliknya.

Untuk kafe yang sudah ada, misalnya `kissa-haus-coffee-shop`, simpan foto berizin sebagai `public/images/kissa-haus-coffee-shop/depan.jpg`, kemudian isi field `foto` pada objek tersebut:

```json
"foto": [
  { "src": "depan.jpg", "alt": "Deskripsi faktual isi foto yang kamu unggah" }
]
```

Nama file string seperti `"depan.jpg"` juga didukung. Bentuk `/images/<slug>/depan.jpg` dapat dipakai. Path harus tetap di dalam folder kafe bersangkutan. Untuk menu, isi field `foto` menu dengan nama file atau objek `src`/`alt` yang sama. Isi `sumber_foto` dengan kredit yang benar; kredit akan tampil pada halaman detail.

Saat build, Sharp melakukan orientasi EXIF, resize maksimal 480/960/1440 px tanpa memperbesar sumber kecil, konversi WebP kualitas 82, dan memberi nama berbasis hash. HTML memakai `srcset`, `width`, `height`, serta lazy loading; foto utama diberi prioritas. Metadata file asli tidak diteruskan. File yang dirujuk tetapi belum tersedia memakai placeholder. File rusak atau path tidak aman menggagalkan build agar masalah terlihat.

```bash
# Dengan Node >=20 pada komputer lokal
npm ci
npm run check-images
npm run build
npm test

# Alternatif lewat image build Docker, tanpa Node di host
docker build --target build -t bento-kopi-build .
docker run --rm bento-kopi-build npm run check-images
```

`check-images` melaporkan kafe tanpa foto lokal, referensi file hilang, dan setiap menu tanpa foto. Status keluar 0 untuk foto draf yang belum diisi; JSON/path invalid menghasilkan error. Foto yang tidak dirujuk di JSON tidak ditampilkan.

## Font dan tampilan

Fraunces 600 untuk display dan DM Sans 400 untuk body disertakan sebagai WOFF2 lokal, subset Latin. Paket asal: `@fontsource/fraunces@5.3.0` dan `@fontsource/dm-sans@5.3.0`. Lisensi SIL OFL ada di `public/fonts/`. Tidak ada Google Fonts/CDN saat runtime. Palet empat warna: krem `#f5efdf`, cokelat `#30271f`, merah bata `#a63e2b`, pasir `#ded4bb`.

## Nomor WhatsApp dan domain

```bash
cp .env.example .env
```

Isi `.env` sebelum build: `SITE_URL` adalah origin publik tanpa subpath, misalnya domain milikmu dengan HTTPS; `WHATSAPP_NUMBER` adalah nomor pengelola dalam format internasional angka saja (awalan 62, tanpa + atau spasi).

Nomor awal `[ISI: nomor WA]` sengaja tidak menjadi tautan WhatsApp aktif. Setelah nomor valid diisi dan situs dibangun ulang, tombol WhatsApp otomatis aktif. Nomor kafe di JSON tidak digunakan sebagai nomor pengelola direktori.

`SITE_URL` dipakai untuk canonical, Open Graph, JSON-LD, sitemap dan robots. Default `http://localhost:8080` hanya untuk lokal; ubah sebelum VPS. Halaman kafe memiliki schema `CafeOrCoffeeShop` berdasarkan data yang tersedia, tanpa rating atau testimoni buatan. Open Graph image hanya ada ketika foto lokal benar-benar tersedia.

## Mode pengembangan opsional

```bash
npm ci
npm run dev
```

Server lokal tersedia di port 8080. Data, foto, source, dan skrip dipantau; setelah perubahan, build berjalan otomatis. Refresh browser untuk melihat hasil. Mode ini bukan server produksi.

Atau, hentikan layanan produksi lalu jalankan Compose dev dengan bind mount:

```bash
docker compose down
docker compose -f docker-compose.dev.yml up
```

Folder proyek, `data/`, dan `public/images/` di-mount langsung. User `node` (UID 1000) perlu izin tulis ke folder proyek untuk `node_modules/` dan `dist/`. Dev menjalankan `npm ci` untuk platform container; jika kembali menjalankan Node di host dengan platform berbeda, jalankan `npm ci` lagi di host. Dev tidak memerlukan rebuild image setiap perubahan data/foto. Perubahan `package.json`/lockfile memerlukan restart dev. Produksi selalu perlu build ulang setelah perubahan data/foto.

## Deploy VPS

1. Pasang Docker Engine + Compose v2 pada VPS Linux, lalu salin seluruh folder proyek.
2. Isi `.env` dengan domain publik dan nomor WhatsApp pengelola.
3. Jalankan `docker compose up -d --build` dan pemeriksaan HTTP di atas.
4. Arahkan DNS domain ke VPS. Pasang reverse proxy TLS di depan `127.0.0.1:8080` dengan sertifikat domain. Jika hanya reverse proxy yang mengaksesnya, ubah pemetaan Compose menjadi `127.0.0.1:8080:80`.
5. Setelah perubahan, jalankan build ulang. Cadangkan `data/` dan `public/images/`.

Runtime Nginx menyediakan gzip, cache satu tahun untuk aset/gambar ber-hash, revalidasi HTML, URL direktori, header keamanan, dan 404 kustom. Build memerlukan internet; runtime tidak memiliki dependensi jaringan luar untuk memuat halaman. Tombol Maps/Instagram/WhatsApp baru membuka domain luar ketika pengguna mengkliknya.

## Memeriksa kualitas

Jalankan `npm run build && npm test`. Tes mencakup jam lintas hari, pengecualian hari, filter, rekomendasi, nilai kosong, SEO, keutuhan JSON, dan optimasi gambar sementara. Lihat `VERIFIKASI.md` untuk hasil aktual dan batas pengujian paket ini.

Di browser, cek lebar 390 px dan desktop, navigasi Tab, reset filter, hasil kosong, halaman detail langsung, tautan kontak, serta 404. Jalankan Lighthouse dengan mode Mobile pada URL VPS atau localhost (browser desktop) untuk mengukur target 90+. Skor tidak dijamin tanpa pengukuran; ukuran dan jumlah foto yang ditambahkan dapat memengaruhi hasil.
