# Aplikasi Money Tracker

Repositori ini berisi kode untuk aplikasi Money Tracker, termasuk backend yang dibangun dengan Express.js, frontend yang dibangun dengan Flutter dan dump database dalam format SQL. Berikut adalah instruksi untuk mengatur dan menjalankan proyek ini di mesin lokal Anda.

## Daftar Isi
1. [Prasyarat](#prasyarat)
2. [Set-up Database](#setup-database)
3. [Set-up Backend](#setup-backend)
4. [Set-up Frontend](#setup-frontend)



## Pra-syarat
- Node.js dan npm terinstal di mesin Anda. [Unduh di sini](https://nodejs.org/)
- Flutter terinstal di mesin Anda. [Mulai dengan Flutter](https://flutter.dev/docs/get-started/install)
- MySQL terinstal di mesin Anda. [Unduh di sini](https://www.mysql.com/downloads/)
- Git terinstal di mesin Anda. [Unduh di sini](https://git-scm.com/)

## Set-up Database
1. Buat database baru di MySQL:
    ```sql
    CREATE DATABASE money_tracker;
    ```

2. Impor file dump SQL:
    ```bash
    mysql -u user_database_anda -p money_tracker < path/to/uangkoo.sql
    ```


## Set-up Backend
1. Clone repositori ini:
   ```bash
   git clone https://github.com/sirozulhuda/final_project_uas.git
   cd be_final_project
    ```

2. Instal dependensi yang diperlukan:
    ```bash
    npm install
    ```

3. Konfigurasi variabel lingkungan:
    Buat file `.env` di direktori `backend` dengan konten berikut:
    ```plaintext
    DB_HOST=host_database_anda
    DB_USER=user_database_anda
    DB_PASSWORD=password_database_anda
    DB_NAME=nama_database_anda
    ```

4. Jalankan server backend:
    ```bash
    npm start
    ```

## Set-up Frontend
1. Clone repositori ini:
   ```bash
   git clone https://github.com/sirozulhuda/final_project_uas.git
   cd fe_final_project
    ```

3. Dapatkan dependensi Flutter:
    ```bash
    flutter pub get
    ```

4. Jalankan aplikasi Flutter:
    ```bash
    flutter run
    ```



## Informasi Tambahan
- Untuk masalah atau kontribusi, silakan buka issue atau kirim pull request.
- Untuk dokumentasi detail, lihat `manual_book.pdf`.

Terima kasih telah mengunjungi repository saya😉!

---
