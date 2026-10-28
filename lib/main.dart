import 'dart:math';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// ---------- WARNA ----------
const Color warnaUtama = Color(0xFF6C63FF);
const Color warnaUtamaMuda = Color(0xFF9D8CFF);
const Color warnaAksen = Color(0xFF00C2A8);
const Color warnaLatar = Color(0xFFF5F6FA);
const Color warnaTeks = Color(0xFF1E1F2B);
const Color warnaTeksRedup = Color(0xFF7A7D8C);

const LinearGradient gradasiUtama = LinearGradient(
  colors: [warnaUtama, warnaUtamaMuda],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Map<String, Color> warnaKategori = {
  'Keluarga': Color(0xFFFF6B8A),
  'Teman': Color(0xFF00C2A8),
  'Kerja': Color(0xFFFFA726),
  'Kampus': Color(0xFF6C63FF,) };

// ---------- MODEL ----------
class Kontak {
  final String nama;
  final String nim;
  final String kampus;
  final String telepon;
  final String email;
  final String kategori;
  final DateTime ditambahkan;

  Kontak({
    required this.nama,
    required this.nim,
    required this.kampus,
    required this.telepon,
    required this.email,
    required this.kategori,
    required this.ditambahkan,
  });
}

const List<String> daftarKategori = ['Keluarga', 'Teman', 'Kerja', 'Kampus'];

const List<String> daftarNama = [
  'Budi Santoso',
  'Siti Nurhaliza',
  'Agus Prasetyo',
  'Dewi Lestari',
  'Rizky Ramadhan',
  'Putri Maharani',
  'Fajar Nugroho',
  'Ayu Wulandari',
  'Dimas Aditya',
  'Nur Aini',
  'Eko Saputra',
  'Rina Marlina',
  'Hendra Wijaya',
  'Lia Anggraini',
  'Yoga Pratama',
  'Intan Permata',
  'Bayu Setiawan',
  'Sari Handayani',
  'Andi Kurniawan',
  'Maya Safitri',
];

const List<String> daftarKampus = [
  'Universitas Gadjah Mada',
  'Universitas Indonesia',
  'Institut Teknologi Bandung',
  'Universitas Diponegoro',
  'Universitas Negeri Semarang',
  'Universitas Sebelas Maret',
];

// ---------- DATA DUMMY (Tanpa Faker Error) ----------
List<Kontak> buatKontak() {
  final rnd = Random();

  return daftarNama.map((nama) {
    final angkatan = rnd.nextInt(5) + 21; // Angkatan 21 - 25
    final urut = rnd.nextInt(999).toString().padLeft(3, '0');
    final nim = '41$angkatan$urut';
    final kampus = daftarKampus[rnd.nextInt(daftarKampus.length)];
    final kategori = daftarKategori[rnd.nextInt(daftarKategori.length)];

    final telpNo = rnd.nextInt(90000000) + 10000000;
    final telepon = '08${rnd.nextInt(9)}$telpNo';
    final email = '${nama.toLowerCase().replaceAll(' ', '.')}@mhs.ac.id';
    final ditambahkan = DateTime.now().subtract(Duration(days: rnd.nextInt(365)));

    return Kontak(
      nama: nama,
      nim: nim,
      kampus: kampus,
      telepon: telepon,
      email: email,
      kategori: kategori,
      ditambahkan: ditambahkan,
    );
  }).toList();
}

final List<Kontak> semuaKontak = buatKontak();

// ---------- MAIN ----------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Kontak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: warnaUtama,
        useMaterial3: true,
        scaffoldBackgroundColor: warnaLatar,
      ),
      home: const HalamanUtama(),
    );
  }
}

// ---------- HALAMAN UTAMA ----------
class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _index = 0;

  final List<Widget> _halaman = const [
    HalamanKontak(),
    HalamanCari(),
    HalamanProfil(),
  ];

  final List<String> _judul = const ['Kontak', 'Cari', 'Profil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _judul[_index],
          style: const TextStyle(
            color: warnaTeks,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: IndexedStack(index: _index, children: _halaman),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        gradient: gradasiUtama,
        activeColor: Colors.white,
        color: Colors.white70,
        initialActiveIndex: 0,
        items: const [
          TabItem(icon: Icons.contacts_rounded, title: 'Kontak'),
          TabItem(icon: Icons.search_rounded, title: 'Cari'),
          TabItem(icon: Icons.person_rounded, title: 'Profil'),
        ],
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ---------- ITEM KONTAK ----------
class ItemKontak extends StatelessWidget {
  final Kontak kontak;
  const ItemKontak({super.key, required this.kontak});

  @override
  Widget build(BuildContext context) {
    final tanggal = DateFormat('dd MMMM yyyy', 'id_ID').format(kontak.ditambahkan);
    final warna = warnaKategori[kontak.kategori] ?? warnaUtama;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: warnaUtama.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: gradasiUtama,
              shape: BoxShape.circle,
            ),
            child: Text(
              kontak.nama[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        kontak.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: warnaTeks,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: warna.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        kontak.kategori,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: warna,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _baris(Icons.badge_outlined, 'NIM ${kontak.nim}'),
                _baris(Icons.school_outlined, kontak.kampus),
                _baris(Icons.phone_outlined, kontak.telepon),
                _baris(Icons.email_outlined, kontak.email),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event_rounded, size: 14, color: warnaAksen),
                    const SizedBox(width: 6),
                    Text(
                      'Ditambahkan pada $tanggal',
                      style: const TextStyle(
                        fontSize: 12,
                        color: warnaAksen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _baris(IconData ikon, String teks) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(ikon, size: 14, color: warnaTeksRedup),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              teks,
              style: const TextStyle(fontSize: 13, color: warnaTeksRedup),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- HALAMAN 1: KONTAK ----------
class HalamanKontak extends StatelessWidget {
  const HalamanKontak({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      itemCount: semuaKontak.length,
      itemBuilder: (context, index) {
        return ItemKontak(kontak: semuaKontak[index]);
      },
    );
  }
}

// ---------- HALAMAN 2: CARI ----------
class HalamanCari extends StatefulWidget {
  const HalamanCari({super.key});

  @override
  State<HalamanCari> createState() => _HalamanCariState();
}

class _HalamanCariState extends State<HalamanCari> {
  String? _kategoriDipilih;

  @override
  Widget build(BuildContext context) {
    final hasil = _kategoriDipilih == null
        ? <Kontak>[]
        : semuaKontak.where((k) => k.kategori == _kategoriDipilih).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: DropdownSearch<String>(
            items: daftarKategori,
            selectedItem: _kategoriDipilih,
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Cari kategori...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Kategori kontak',
                hintText: 'Pilih kategori',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.category_rounded, color: warnaUtama),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: warnaUtama, width: 2),
                ),
              ),
            ),
            onChanged: (nilai) => setState(() => _kategoriDipilih = nilai),
          ),
        ),
        Expanded(
          child: _kategoriDipilih == null
              ? const Center(
            child: Text(
              'Pilih kategori untuk melihat kontak',
              style: TextStyle(color: warnaTeksRedup),
            ),
          )
              : hasil.isEmpty
              ? const Center(
            child: Text(
              'Tidak ada kontak di kategori ini',
              style: TextStyle(color: warnaTeksRedup),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: hasil.length,
            itemBuilder: (context, i) => ItemKontak(kontak: hasil[i]),
          ),
        ),
      ],
    );
  }
}

// ---------- HALAMAN 3: PROFIL ----------
class HalamanProfil extends StatelessWidget {
  const HalamanProfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36),
          decoration: const BoxDecoration(
            gradient: gradasiUtama,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
          child: Column(
            children: [
              AvatarGlow(
                glowColor: Colors.white,
                child: const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Riyan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mahasiswa Sistem Informasi',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _infoProfil(Icons.school_rounded, 'Program Studi', 'Sistem Informasi'),
        _infoProfil(Icons.book_rounded, 'Mata Kuliah', 'Mobile Programming'),
        _infoProfil(Icons.contacts_rounded, 'Total Kontak', '${semuaKontak.length} kontak'),
      ],
    );
  }

  Widget _infoProfil(IconData ikon, String judul, String isi) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: warnaUtama.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
          children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: warnaUtama.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
       ),
       child: Icon(ikon, color: warnaUtama, size: 20),
      ),
      const SizedBox(width: 14),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: TextStyle(fontSize: 12, color: warnaTeksRedup),
              ),
              Text(
                isi,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: warnaTeks,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}