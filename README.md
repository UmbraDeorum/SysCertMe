# SysCertMe
Install a certificate to Android's system certificate store, and implement bypass Chromium's certificate transparency.

## 🚀 Features

- **System Certificate Installation**: Adds custom CA certificates to Android's system trust store
- **Chromium Bypass**: Configures Chromium-based browsers to ignore certificate errors for your certificate
- **Root Access Automation**: Handles ADB root access and system partition remounting
- **Certificate Validation**: Automatically calculates certificate hashes and formats
- **SELinux Compliance**: Sets proper file contexts and permissions

## 📋 Prerequisites

- **Rooted Android device** or emulator with ADB debugging enabled
- **ADB** installed on your computer
- **OpenSSL** for certificate processing
- **System partition** must be writable

## 🛠️ Usage

```bash
# Make script executable
chmod +x sys_cert_me.sh

# Run with your certificate file
./sys_cert_me.sh your_certificate.der
```

## 📁 Supported Certificate Formats

The script requires certificates in **DER format**. Convert other formats using:

```bash
# Convert PEM to DER
openssl x509 -in certificate.pem -outform DER -out certificate.der

# Convert CRT to DER  
openssl x509 -in certificate.crt -outform DER -out certificate.der
```

## 🔧 What the Script Does

### 1. **System Certificate Installation**
- Converts DER certificate to proper PEM format with hash-based filename
- Pushes certificate to `/system/etc/security/cacerts/`
- Sets correct permissions (644) and SELinux context
- Makes certificate trusted system-wide

### 2. **Chromium Bypass Configuration**
- Calculates SPKI fingerprint for certificate pinning bypass
- Creates command-line files for Chromium-based applications:
  - Chrome browser
  - Android WebView
  - Content Shell
- Sets appropriate permissions and restarts Chrome

## 🎯 Supported Applications

The bypass works for:
- **Google Chrome** (`com.android.chrome`)
- **Android System WebView**
- **Content Shell applications**
- **Other Chromium-based browsers**

## ⚠️ Important Notes

- **Root access required** - only works on rooted devices
- **System modifications** - changes persist across reboots
- **Security consideration** - only use with trusted certificates
- **Test thoroughly** - may affect system security and app functionality

## 🔍 Verification

After running the script, verify the installation:

```bash
# Check certificate file
adb shell ls -la /system/etc/security/cacerts/ | grep your_cert_hash

# Check Chromium command-line files
adb shell ls -la /data/local/*-command-line
```

## 🗑️ Cleanup

The script automatically cleans up temporary files. To remove installed certificates manually:

```bash
adb shell rm /system/etc/security/cacerts/your_cert_hash.0
adb shell rm /data/local/*-command-line
adb shell rm /data/local/tmp/*-command-line
```

## 🐛 Troubleshooting

**SELinux blocking operations:**

```bash
# Temporarily set permissive (development only)
adb shell setenforce 0
```

**Certificate not trusted:**
- Ensure certificate is in proper DER format
- Verify device has proper root access
- Check if system partition is writable

---

**Note**: Use this tool responsibly and only on devices you own or have permission to modify.
