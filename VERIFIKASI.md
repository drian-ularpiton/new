# Hasil verifikasi

## Lulus

- Data lampiran dan `data/cafes.json` identik byte demi byte.
- SHA-256 sumber: `dbc371c50bb621884b9ae52ea2c168b4f34ccc4927d81b1a9b662da8e0a1de56`.
- Build generator berhasil dengan Node v20.20.2.
- 8 tes otomatis lulus, 0 gagal pada Node 20.
- 16 detail kafe + beranda + Tentang + 404 dihasilkan; sitemap berisi 18 URL indeks.
- Seluruh 16 format jam buka awal dapat diparse. Perhitungan memakai WIB, termasuk lintas tengah malam, 24 jam, dan pengecualian Kamis.
- Tes mencakup filter gabungan, keadaan tanpa hasil, rekomendasi 3 kafe, data kosong, properti JSON-LD, kesamaan byte data, path gambar tidak aman, file rusak, serta output WebP 480/960/1440 px.
- Pemeriksaan gambar melaporkan 16 kafe dan 27 menu tanpa foto lokal.
- YAML kedua file Compose dapat diparse.
- Pratinjau desktop di browser menampilkan beranda, detail My Way Café, Tentang, dan halaman 404 kustom.
- Interaksi browser: filter Patrang menghasilkan Lofi Space & Garden; WiFi + Rp menghasilkan My Way Café; pencarian tak cocok menampilkan keadaan kosong; Nugas + buka sekarang menggabungkan kondisi; reset filter mengembalikan 16 kafe dan membersihkan query URL.
- Bug urutan event reset native ditemukan lewat uji browser lalu diperbaiki dan diverifikasi ulang.
- Tidak ada tag gambar, skrip, stylesheet, atau font yang mengambil aset eksternal. Tautan kontak/Maps tetap eksternal dan dibuka hanya oleh pengguna.

## Belum diverifikasi

- `docker compose up` dan `nginx -t` belum dieksekusi: Docker CLI/daemon dan Nginx tidak tersedia di lingkungan pengerjaan. Konfigurasi multi-stage, non-root, healthcheck, cache, gzip, dan 404 telah disiapkan, tetapi ini bukan klaim uji container berhasil.
- Pemeriksaan HTTP langsung dari proses shell ke server pratinjau tidak tersedia (koneksi ditolak); validasi browser menggunakan jalur pratinjau yang disediakan. Status HTTP produksi tetap harus dicek dengan perintah README.
- Lighthouse mobile belum dijalankan; target 90+ belum memiliki skor pengukuran.
- Tata letak mobile memakai CSS mobile-first, tetapi viewport ponsel belum diuji di browser sesi ini.
- Kontak bisnis, jam buka aktual, harga, hak penggunaan foto, dan tautan luar tidak diverifikasi; data draf tetap apa adanya.

## Ulangi pada komputer/VPS

```bash
docker compose config
docker compose up -d --build
docker compose ps
docker compose exec web nginx -t
curl -I http://localhost:8080/
curl -I http://localhost:8080/kafe/kissa-haus-coffee-shop/
curl -I http://localhost:8080/tentang/
curl -I http://localhost:8080/tidak-ada/
```

Harapan: halaman valid 200, halaman tidak ada 404, container menjadi healthy. Periksa tampilan pada lebar 390 px dan jalankan Lighthouse Mobile sebelum publikasi.
