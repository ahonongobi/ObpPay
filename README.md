
---

# 🟦 **README.md — OBPPay**

```markdown
# 💳 OBPPay — Mobile Money & Digital Wallet App

OBPPay is a modern **mobile money & digital wallet application** designed for fast, secure, and intuitive financial operations.  
The project includes wallet management, transfers, deposits, marketplace interactions, loan requests, and a premium onboarding experience.

Built entirely with **Flutter**, OBPPay provides a smooth user experience and a scalable architecture ready for production.

---

## 🚀 Features

### 🏦 **Wallet & Account Management**
- View account balance in real time  
- Recent transactions list  
- Action shortcuts (Deposit, Withdraw, Transfer, Marketplace)

### 💰 **Money Operations**
- Deposit & withdraw  
- Transfer funds to other users (internal money transfer)  
- All transactions displayed with clean UI components

### 🛒 **Marketplace Module**
- Browse and buy digital/physical items  
- Integrated storefront view

### 📲 **Slide-In Curved Drawer Menu**
A custom animated side drawer:
- Opens with a curved animation  
- Hamburger button rotates on tap  
- Contains navigation shortcuts  
- Supports extra pages (e.g., Loan Requests)

### 📝 **Loan Request System**
- Choose a loan category  
- Support for custom ("Other") categories  
- Eligibility evaluation with a **premium gradient bar**  
- Loan amount input (only when eligible)  
- Submission screen ready for backend integration

### 🎯 **Quick Tour / Onboarding**
Using `showcaseview`, OBPPay guides new users through:
- Menu button  
- Wallet balance  
- Important actions (Deposit, Transfer)  
- Only triggered on first launch (configurable)

### 🌙 **Dark & Light Mode**
- Fully supports theme switching  
- Theme stored via Provider and updated globally

---

## 📁 Project Structure

```

lib/
│
├── main.dart                       # App entry point
├── themes/                         # Light & Dark theme definitions
├── providers/                      # Theme & User state providers
│
├── screens/
│   ├── splash_screen.dart          # Initial splash screen
│   ├── dashboard_screen.dart       # Main wallet dashboard
│   ├── deposit_screen.dart         # Deposit money
│   ├── transfer_screen.dart        # Transfer money
│   ├── marketplace_screen.dart     # Marketplace
│   ├── profile_screen.dart         # User profile
│   ├── loan_request_screen.dart    # Loan/aide request module
│   ├── main_layout.dart            # Home screen with bottom nav & drawer
│
├── widgets/                        # Reusable components (if added)
└── themes/                         # App color scheme, styles

````

---

## 🛠️ Technologies

| Technology | Purpose |
|-----------|---------|
| **Flutter** | Cross-platform mobile app |
| **Provider** | State management |
| **ShowCaseView** | Intro guide / Quick Tour |
| **Dart** | Core language |
| **Custom Animations** | Drawer, gradient bars |
| **Material UI** | Base components |

---

## 🎨 UI & Design Highlights

- Custom curved right-side hamburger menu  
- Smooth transition animations  
- Gradient eligibility bar  
- Professional spacing, shadows, and color palette  
- Icons, rounded components, modern layout standards  

---

## 🧠 State Management

OBPPay uses **Provider** to handle:

- Theme switching  
- User session & profile  
- Future extension: auth, transactions, loan requests  

Providers are initialized in `main.dart` using `MultiProvider`.

---

## 💡 Quick Tour (Onboarding)

The quick tour is implemented using `showcaseview`.

### Highlighted elements:
- Hamburger menu  
- Wallet balance  
- Deposit & Transfer buttons  

### How it works:
1. Keys are defined in `MainLayout`
2. Widgets are wrapped with `Showcase()`
3. On first layout render, the tour starts automatically  
4. (Optional) Can be stored in `SharedPreferences` to show only once  

---

## 📦 Installation & Setup

### 1. Clone the repo
```bash
git clone https://github.com/<username>/obppay.git
cd obppay
````

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

### 4. (Optionnel) Build APK

```bash
flutter build apk
```

---

## 🔌 Backend Integration

OBPPay is designed to integrate with any backend (Laravel, Node.js, Django…).
Typical endpoints:

* `/auth/login`
* `/wallet/balance`
* `/wallet/transactions`
* `/transfer/send`
* `/loan/request`

The structure is ready for API integration via:

```dart
http
dio
retrofit
```

depending on your preference.

---

## 🔐 Security Considerations

* Sensitive actions can use OTP verification
* UserProvider stores authentication tokens
* API requests (future) should use HTTPS
* Secure local storage recommended for tokens

---

## 🎯 Roadmap

### Planned features:

* 🔐 OTP login flow
* 📍 Nearest OBP agencies
* 🧾 Transaction receipts (PDF)
* 📊 Loan eligibility calculator with scoring
* 🔔 Push notifications
* 🌐 Full backend integration
* 💳 Virtual card generation

---

## 👨‍💻 Author

**Gobi-a P. Ahonon**
Software Engineering • Machine Learning • AI Researcher
🇨🇭 Based in Switzerland • 🇧🇯 From Benin
📘 Passionate about fintech, systems intelligence & UX quality

---

## ⭐ Contribution

Open to contributions!
Please follow the PR template and coding style.

---

## 📜 License

MIT License © 2025 OBPPay

---

```

---

## 📱 Screenshots

### Dashboard
<img src="assets/screenshots/dashboard.png" width="300">

### Side Menu
<img src="assets/screenshots/menu.png" width="300">

### Loan Request Screen
<img src="assets/screenshots/loan.png" width="300">

```
