# 🎬 Watchly - Presentation Script
## Authentication & User Management Features

---

## 📱 1. Authentication System

### 1.1 Login Screen

**Narasi:**
> "Halaman login Watchly dirancang dengan UI modern dan dark theme yang nyaman di mata. User bisa login menggunakan **email atau username** - fleksibilitas yang meningkatkan user experience."

**Fitur yang ditampilkan:**
- ✅ Input email/username dengan validasi
- ✅ Password field dengan toggle visibility
- ✅ "Forgot Password" link untuk reset password
- ✅ Social login buttons (Google & Apple) - *coming soon*
- ✅ Link ke halaman Sign Up

**Demo Flow:**
1. Masukkan email/username yang sudah terdaftar
2. Masukkan password
3. Klik "Log In"
4. *Loading indicator muncul*
5. Redirect ke Home screen setelah sukses

**Error Handling Demo:**
- Matikan internet → Muncul error: *"No internet connection"*
- Masukkan password salah → Muncul error dari Firebase

---

### 1.2 Sign Up Screen

**Narasi:**
> "Proses registrasi yang simpel namun aman. Kita menggunakan **Firebase Authentication** untuk keamanan dan **Firebase Realtime Database** untuk menyimpan profil user."

**Fitur yang ditampilkan:**
- ✅ Full Name input
- ✅ Username unik (validasi real-time)
- ✅ Email dengan format validation
- ✅ Password dengan minimum 6 karakter
- ✅ Confirm Password matching validation
- ✅ Social signup options

**Demo Flow:**
1. Isi semua field dengan data valid
2. Klik "Create Account"
3. *Loading indicator muncul*
4. Otomatis login dan redirect ke Home screen

**Validasi yang ditampilkan:**
- Username hanya boleh: huruf, angka, underscore
- Email harus format valid
- Password minimal 6 karakter
- Confirm password harus cocok

---

### 1.3 Forgot Password

**Narasi:**
> "Jika user lupa password, mereka bisa request reset link yang akan dikirim ke email terdaftar melalui **Firebase Authentication**."

**Demo Flow:**
1. Klik "Forgot Password?" di login screen
2. Masukkan email terdaftar
3. Klik "Send Reset Link"
4. Muncul success message
5. User cek email → Klik link → Set password baru

---

### 1.4 Network Error Handling

**Narasi:**
> "Aplikasi kami memiliki **robust error handling** untuk berbagai kondisi jaringan."

**Demo Scenarios:**

| Kondisi | Response |
|---------|----------|
| Tidak ada internet | Langsung error: *"No internet connection"* |
| Koneksi lambat (>15s) | Timeout: *"Connection timeout. Please try again."* |
| Firebase error | User-friendly message yang relevan |

---

## 👥 2. User Management (Admin Panel)

### 2.1 Admin User List

**Narasi:**
> "Admin memiliki akses ke **User Management Panel** untuk melihat dan mengelola semua user yang terdaftar di aplikasi."

**Fitur yang ditampilkan:**
- ✅ List semua users dengan real-time updates
- ✅ Search dan filter users
- ✅ Responsive layout (mobile: cards, desktop: data table)
- ✅ User details: nama, email, username, role, tanggal daftar

**Role-based Access:**
- **User biasa**: Tidak bisa akses admin panel
- **Admin**: Full access ke user management

---

### 2.2 User Role Management

**Narasi:**
> "Admin dapat mengubah role user antara **user** dan **admin**. Semua perubahan diproteksi oleh **Firebase Security Rules**."

**Demo Flow:**
1. Login sebagai admin
2. Buka Admin Panel
3. Pilih user dari list
4. Klik Change Role
5. Pilih role baru
6. *Role updated successfully*

**Security Rules Demo:**
- Login sebagai **user biasa**
- Coba ubah role diri sendiri
- Muncul error: *"Permission denied. You don't have access to perform this action."*

---

### 2.3 Firebase Security Rules

**Narasi:**
> "Keamanan data dijaga dengan **Firebase Realtime Database Security Rules** yang ketat."

**Rules yang diterapkan:**

```
┌─────────────────────────────────────────────────────────┐
│                    SECURITY RULES                        │
├─────────────────────────────────────────────────────────┤
│ READ users     → Hanya authenticated users              │
│ WRITE profile  → Hanya owner atau admin                 │
│ CHANGE role    → Hanya admin (tidak bisa ubah sendiri)  │
│ DELETE user    → Hanya admin                            │
└─────────────────────────────────────────────────────────┘
```

---

## 🏗️ 3. Technical Architecture

### Clean Architecture

```
┌──────────────────────────────────────────────┐
│              PRESENTATION LAYER              │
│   (Screens, Widgets, Riverpod Providers)     │
├──────────────────────────────────────────────┤
│               DOMAIN LAYER                   │
│       (Entities, Repositories, Use Cases)    │
├──────────────────────────────────────────────┤
│                DATA LAYER                    │
│    (Firebase DataSources, Models, Repos)     │
└──────────────────────────────────────────────┘
```

### Technology Stack

| Layer | Technology |
|-------|------------|
| UI Framework | Flutter 3.x |
| State Management | Riverpod |
| Navigation | GoRouter |
| Authentication | Firebase Auth |
| Database | Firebase Realtime Database |
| Network Check | connectivity_plus |

---

## 📊 4. Demo Checklist

### Pre-Demo Setup:
- [ ] Pastikan ada akun admin dan akun user biasa
- [ ] Pastikan internet connection stabil
- [ ] Buka Firebase Console untuk show real-time data

### Login Flow:
- [ ] Show login dengan email
- [ ] Show login dengan username
- [ ] Demo wrong password error
- [ ] Demo no internet error

### Signup Flow:
- [ ] Show full registration process
- [ ] Demo username validation
- [ ] Show auto-login after registration

### Admin Panel:
- [ ] Show user list (real-time)
- [ ] Demo change role (as admin)
- [ ] Demo permission denied (as user)
- [ ] Show responsive layout (mobile vs desktop)

---

## 🎯 5. Key Takeaways

1. **Secure** - Firebase Authentication + Security Rules
2. **User-Friendly** - Clear error messages, smooth UX
3. **Robust** - Network error handling, timeout protection
4. **Scalable** - Clean Architecture, easy to maintain
5. **Responsive** - Works on mobile, tablet, and desktop

---

*Prepared for Watchly App Presentation*
