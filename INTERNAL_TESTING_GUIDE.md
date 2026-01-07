# 📱 Watchly - Internal Testing Guide

**Version:** 1.0.0  
**Build Date:** 19 Desember 2025  
**Minimum Android:** 5.0 (Lollipop)

---

## 🎯 Apa yang Harus Ditest?

Terima kasih sudah membantu testing! Fokus testing pada area berikut:

### 1. ✅ Basic Functionality
- [ ] App bisa dibuka tanpa crash
- [ ] Login & Register berfungsi
- [ ] Bisa lihat daftar movie & TV shows
- [ ] Search berfungsi
- [ ] Detail movie/TV show tampil dengan benar
- [ ] Favorites bisa add/remove

### 📱 Boleh Pakai Emulator?

**Short Answer:** Boleh, tapi dengan catatan! ⚠️

#### ✅ BOLEH pakai emulator untuk:
- Quick UI testing (layout, navigation)
- Basic flow testing (login, browse)
- Network request testing

#### ❌ TIDAK RELIABLE untuk:
- Camera/Image picker functionality (sering crash)
- Performance testing (emulator lebih lambat)
- Final validation sebelum release

#### 🎯 Recommendation:
Pakai emulator untuk **initial testing** (cepat & mudah), tapi **WAJIB konfirmasi di physical device** untuk bugs yang serius.

**Rule of Thumb:**
- Bug di emulator + bug di physical device = 🔴 **Real bug, report!**
- Bug di emulator ONLY = ⚪ **Might be emulator issue, test di device dulu**
- Bug di physical device only = 🔴 **Real bug, report!**


### 2. 🌐 Network Testing
- [ ] Test dengan WiFi
- [ ] Test dengan mobile data (3G/4G/5G)
- [ ] Test dengan network lambat
- [ ] **PENTING:** Test dengan airplane mode → buka app → disable airplane mode (seharusnya show error lalu bisa retry)

### 3. 📱 Device Compatibility
- [ ] Test di berbagai ukuran layar (phone/tablet)
- [ ] Test rotate landscape/portrait
- [ ] Test dengan dark mode/light mode (jika support)

### 4. 🔄 User Flow Testing
- [ ] Register → Login → Browse movies → Add favorite → Logout → Login lagi (favorite masih ada?)
- [ ] Search movie → View details → Back → Search lagi
- [ ] Scroll daftar movie sampai bawah (pagination should load more)

---

## 🐛 Cara Melaporkan Bug

### Format Laporan Bug:

```
**Judul Bug:** [Singkat & jelas]

**Langkah Reproduksi:**
1. Buka app
2. Klik button X
3. Input Y
4. Klik Z

**Expected:** Apa yang seharusnya terjadi
**Actual:** Apa yang benar-benar terjadi

**Device Info:**
- Model: [e.g., Samsung Galaxy S21]
- Android Version: [e.g., Android 12]
- Network: [WiFi/3G/4G/5G]

**Screenshot:** [Attach jika ada]
```

### Priority Levels:

- 🔴 **CRITICAL:** App crash, tidak bisa dibuka, data hilang
- 🟡 **HIGH:** Fitur utama tidak berfungsi (login, search, dll)
- 🟢 **MEDIUM:** Fitur minor bug, UI issue
- ⚪ **LOW:** Typo, suggestion

---

## 📋 Known Issues (Tidak Perlu Dilaporkan)

### Expected Behavior:
1. ✅ **Network Error saat offline** → Expected, bukan bug
2. ✅ **"App not compatible"** di Android <5.0 → Expected (requirement: Android 5.0+)
3. ✅ **Image loading lambat** di network lambat → Expected behavior

---

## ❓ FAQ

### Q: App bilang "API keys not configured"
**A:** Ini normal di development build. Abaikan warning ini, app tetap berfungsi.

### Q: Kenapa tidak bisa download di Play Store?
**A:** Cek Android version kamu. Minimum requirement: **Android 5.0 (Lollipop)**.

### Q: App crash saat pertama buka
**A:** 🔴 **CRITICAL BUG** - Segera laporkan dengan info:
- Model HP
- Android version
- Screenshot error (jika ada)

### Q: Image tidak muncul/broken
**A:** Periksa:
1. Internet connection OK?
2. Sudah tunggu beberapa detik?
3. Jika masih tidak muncul → Laporkan sebagai bug

### Q: App lambat/lag
**A:** Pastikan:
- Network connection stabil
- HP punya space storage cukup (min 200MB free)
- Tidak ada banyak app lain running background
- Jika masih lambat → Laporkan dengan info device

---

## 🎁 Testing Rewards (Opsional)

**Top 3 Bug Reporters** akan mendapat:
- 🏆 Credit di About page
- 🎬 Premium feature access (jika ada)
- 💝 Terima kasih dari team!

---

## 📞 Kontak

**Bug Reports:** [email/WhatsApp/Slack channel]  
**Questions:** [email developer]

---

## ✨ Tips Testing yang Baik

1. 🔍 **Be Specific:** "Button tidak berfungsi" ❌ → "Login button tidak response saat diklik setelah input email" ✅
2. 📸 **Screenshot:** Gambar berbicara 1000 kata
3. 🔄 **Try Reproduce:** Pastikan bug bisa direproduce (terjadi lagi)
4. 📱 **Device Info:** Selalu sertakan model HP & Android version
5. 🌐 **Network State:** Sebutkan pakai WiFi/mobile data

---

**Terima kasih sudah membantu testing! 🙏**  
**Your feedback makes this app better! 🚀**
