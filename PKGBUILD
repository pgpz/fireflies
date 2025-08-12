pkgname=fireflies
pkgver=1.0.0
pkgrel=1
pkgdesc="A Bash script called fireflies; which puts fireflies on your terminal."
arch=('any')
url="https://github.com/pgpz/fireflies"
license=('MIT')
depends=('bash')
source=(
    "$pkgname.sh"
    "$pkgname.conf"
    "LICENSE"
)
sha256sums=(
    '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
    'abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789'
    'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210'
)

package() {
    install -Dm755 "$srcdir/$pkgname.sh" "$pkgdir/usr/bin/$pkgname"
    install -Dm644 "$srcdir/$pkgname.conf" "$pkgdir/etc/$pkgname.conf"
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
