# Security Policy

## Supported Versions

Currently supported versions for security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue, please follow these steps:

### 1. **DO NOT** Open a Public Issue

Please do not report security vulnerabilities through public GitHub issues.

### 2. Report Privately

Send a detailed report to: [Create a security advisory](https://github.com/pavlenkotm/ethsold/security/advisories/new)

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### 3. Response Time

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Depends on severity

## Security Best Practices

### Smart Contracts

✅ **DO:**
- Audit contracts before mainnet deployment
- Use OpenZeppelin libraries
- Implement access controls
- Add reentrancy guards
- Test thoroughly

❌ **DON'T:**
- Deploy unaudited contracts
- Store private keys in code
- Skip input validation
- Ignore compiler warnings

### Private Keys

🔒 **Never:**
- Commit private keys to Git
- Share private keys
- Store keys in plain text
- Use same key for test and production

✅ **Always:**
- Use hardware wallets
- Implement key rotation
- Use environment variables
- Enable MFA where possible

### DApp Security

- Validate all user inputs
- Sanitize data
- Use HTTPS everywhere
- Implement rate limiting
- Monitor for suspicious activity

### Development

- Keep dependencies updated
- Use Dependabot
- Run security scanners
- Follow principle of least privilege
- Implement logging and monitoring

## Known Issues

None currently.

## Security Tools

We use:
- **Slither** - Solidity static analyzer
- **MythX** - Smart contract security service
- **Dependabot** - Dependency updates
- **GitHub Security Advisories**

## Disclosure Policy

- Responsible disclosure appreciated
- We will acknowledge security researchers
- Public disclosure after fix is deployed
- CVE assignment for critical issues

## Bug Bounty

Currently, we do not offer a bug bounty program. This may change in the future.

## Contact

For security concerns: Use GitHub Security Advisories

For other inquiries: Open a regular GitHub issue

---

**Thank you for helping keep our project secure!** 🔒
