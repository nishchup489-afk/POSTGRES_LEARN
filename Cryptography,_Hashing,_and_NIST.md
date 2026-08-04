
# Cryptography and Security

## Overview

Cryptography protects information using mathematics.

It is commonly used for:

- Password protection
- Secure websites
- Private messages
- Digital signatures
- File integrity
- Payment systems

However, cryptography alone does not make an entire system secure.

---

## Cryptography Is Strong Mathematics

Modern cryptographic algorithms rely on mathematical problems that are extremely difficult to solve without the correct key.

Examples:

| Algorithm | Main use |
|---|---|
| AES | Symmetric encryption |
| RSA | Public-key cryptography |
| SHA-256 | Cryptographic hashing |
| Ed25519 | Digital signatures |

The algorithm may be mathematically secure while the surrounding software is still vulnerable.

---

## Algorithm vs. Implementation

### Algorithm

The mathematical design of the cryptographic system.

### Implementation

The actual software or hardware that performs the algorithm.

A strong algorithm can fail because of:

- Weak passwords
- Leaked secret keys
- Incorrect code
- Poor random-number generation
- Outdated libraries
- Misconfigured servers
- Malware
- Hardware vulnerabilities

---

## The Weakest Link

Security is only as strong as its weakest component.

For example:

> AES encryption may be secure, but if the secret key is uploaded to a public GitHub repository, an attacker does not need to break AES. They can simply steal the key.

---

## Attackers Usually Avoid the Mathematics

Breaking modern cryptographic mathematics directly is usually extremely difficult.

Attackers often choose easier targets:

- Phishing users
- Stealing authentication tokens
- Exploiting application bugs
- Guessing weak passwords
- Reading unprotected backups
- Compromising servers
- Attacking vulnerable dependencies

The attacker usually attacks the system around the cryptography rather than the cryptographic algorithm itself.

---

## What Cryptography Achieves

Strong cryptography increases the cost of an attack.

Without encryption:

```text
An attacker may collect millions of records easily.
````

With properly implemented encryption:

```text
The attacker may need to compromise individual devices,
accounts, servers, or encryption keys.
```

Cryptography does not make attacks impossible.

It makes large-scale attacks more difficult and expensive.

---

## Keep Systems Simple

Complexity creates more opportunities for mistakes and vulnerabilities.

More complexity can mean:

* More bugs
* More configuration errors
* More dependencies
* More attack surfaces
* More difficult testing
* More difficult auditing

Simple systems are generally:

* Easier to understand
* Easier to test
* Easier to audit
* Easier to secure

### Core principle

> Simpler security designs are usually safer than complicated custom systems.

---

## Do Not Invent Your Own Cryptography

Creating your own encryption algorithm is almost always a bad idea.

A homemade algorithm may look secure while containing serious weaknesses that are difficult to notice.

Use:

* Established algorithms
* Publicly reviewed standards
* Trusted cryptographic libraries
* Well-tested implementations

Do not manually implement complex cryptographic algorithms unless you are researching cryptography and fully understand the risks.

---

## Use Modern Standards

Prefer algorithms that have been:

* Publicly documented
* Reviewed by experts
* Tested for many years
* Standardized
* Widely implemented

Modern examples include:

| Standard | Purpose                      |
| -------- | ---------------------------- |
| AES-GCM  | Authenticated encryption     |
| SHA-256  | Integrity hashing            |
| SHA-3    | Cryptographic hashing        |
| Argon2   | Password hashing             |
| TLS      | Secure network communication |

---

## NIST

NIST stands for:

**National Institute of Standards and Technology**

NIST develops and publishes important security standards.

Examples include:

* AES
* SHA-3

---

## Public Cryptographic Competitions

Some cryptographic standards are selected through open competitions.

Researchers submit algorithms.

Other experts attempt to:

* Analyze them
* Find weaknesses
* Compare performance
* Test implementation safety
* Study resistance to known attacks

The strongest designs survive years of public examination.

These competitions help the field improve because weaknesses are discovered before the algorithm becomes widely deployed.

---

## AES

AES is a symmetric encryption algorithm.

Symmetric means:

> The same secret key is used to encrypt and decrypt data.

Conceptually:

```text
Plaintext

"Secret message"

        ↓ Encrypt with secret key

Ciphertext

Unreadable encrypted data

        ↓ Decrypt with the same key

Plaintext

"Secret message"
```

---

## Protect Secret Keys

Encryption security depends heavily on protecting the secret key.

Bad practices:

* Hardcoding keys in source code
* Uploading keys to GitHub
* Sending keys through plain text
* Reusing one key forever
* Sharing production keys with developers unnecessarily

Better practices:

* Store keys in a secret manager
* Restrict access
* Rotate keys
* Separate development and production keys
* Log access to sensitive secrets
* Revoke compromised keys immediately

---

## Randomness Matters

Cryptographic systems often require secure random values.

Examples:

* Encryption keys
* Authentication tokens
* Password salts
* Nonces
* Session identifiers

Normal random-number generators may not be secure enough.

In Python, use:

```python
import secrets

token = secrets.token_hex(32)

print(token)
```

Use `secrets` for security-sensitive values.

Use `random` for:

* Games
* Simulations
* Sampling
* Non-security-related randomness

Do not use `random` for passwords, tokens, or encryption keys.

---

## Encryption Is Not Hashing

### Encryption

* Reversible with a key
* Used when the original data must be recovered

### Hashing

* Designed to be one-way
* Used for fingerprints, integrity checks, and passwords

Example:

```text
Encryption:

message
    ↓ encrypt with key
ciphertext
    ↓ decrypt with key
original message
```

```text
Hashing:

password
    ↓ hash
digest

The original password should not be recoverable from the digest.
```

---

## Encryption Is Not Enough

Encryption mainly provides confidentiality.

A secure system may also need:

### Confidentiality

Unauthorized users cannot read the data.

### Integrity

The data was not changed.

### Authentication

The system verifies who sent the data.

### Authorization

The system decides what a user is allowed to do.

### Availability

The system remains operational and accessible.

This is why modern systems often use authenticated encryption such as AES-GCM.

AES-GCM protects:

* Confidentiality
* Integrity

---

## Password Security

Passwords should not normally be encrypted.

They should be hashed using password-specific algorithms.

Recommended algorithms include:

* Argon2
* bcrypt
* scrypt
* PBKDF2

Avoid storing passwords using:

* Plain text
* MD5
* SHA-1
* Plain SHA-256

Password hashing algorithms are intentionally slow, making password guessing attacks more expensive.

---

## Security Is Adversarial

Security is adversarial.

One side builds defenses.

The other side attempts to break them.

The process looks like this:

```text
Design

    ↓

Attack

    ↓

Discover weakness

    ↓

Improve design

    ↓

Attack again
```

Security systems improve because researchers continuously try to break them.

Failure is part of security research.

Finding a vulnerability helps systems become stronger before attackers exploit it widely.

---

## Complexity Increases Risk

Complex systems are harder to secure because they create more places where mistakes can occur.

Examples of complexity-related risks:

* Too many services
* Too many permissions
* Too many dependencies
* Too many configuration files
* Too many authentication flows
* Too many secrets
* Too much custom security code

Reducing unnecessary complexity reduces the attack surface.

### Attack surface

The attack surface is the collection of all places an attacker might target.

Examples:

* APIs
* Login forms
* Servers
* Databases
* Cloud permissions
* Dependencies
* Employee accounts
* Network ports

A smaller attack surface is usually easier to defend.

---

## Updates Are Part of Security

A system that was secure years ago may no longer be secure today.

Reasons include:

* Algorithms become outdated
* Libraries develop vulnerabilities
* Attack techniques improve
* Hardware becomes faster
* New implementation bugs are discovered

Security requires ongoing maintenance:

* Install security updates
* Remove deprecated algorithms
* Rotate secrets
* Review access permissions
* Monitor suspicious activity
* Patch vulnerable dependencies
* Replace unsupported software

Security is not a one-time feature.

It is a continuous process.

---

## Standardization Builds Trust

Cryptographic standards are more trustworthy when they are:

* Public
* Open to review
* Tested by many researchers
* Documented clearly
* Implemented by multiple independent teams

A secret algorithm is not automatically secure.

Real cryptographic trust usually comes from public analysis over time.

### Core principle

> Security should depend on protecting the key, not hiding how the algorithm works.

This principle is known as Kerckhoffs's principle.

---

## Cryptography Forces Attackers to Prioritize

Without strong encryption, attackers may collect huge amounts of data in bulk.

With strong encryption, attackers may need to compromise:

* One device
* One account
* One server
* One encryption key
* One user at a time

This does not eliminate attacks.

It forces attackers to spend more time, money, and effort on individual targets.

That protects the majority of users from easy mass collection.

---

## Common Implementation Mistakes

Many security failures happen because cryptography is used incorrectly.

Common mistakes include:

* Reusing nonces
* Using weak random values
* Storing keys beside encrypted data
* Using outdated algorithms
* Ignoring certificate validation
* Creating custom encryption
* Logging passwords or tokens
* Using one key for every environment
* Failing to rotate secrets
* Comparing secret values insecurely
* Encrypting data without verifying integrity

Correct implementation matters just as much as choosing a strong algorithm.

---

## Practical Rules

1. Use trusted cryptographic libraries.

2. Do not design your own encryption algorithm.

3. Use modern standardized algorithms.

4. Protect secret keys carefully.

5. Use secure random-number generators.

6. Keep systems as simple as possible.

7. Update libraries and software regularly.

8. Use password-specific hashing algorithms.

9. Remember that attackers often target implementation mistakes instead of mathematics.

10. Treat security as an ongoing process, not a one-time feature.

11. Do not hardcode secrets in source code.

12. Use authenticated encryption when possible.

13. Separate production, development, and testing secrets.

14. Reduce unnecessary permissions and services.

15. Learn from failures and discovered vulnerabilities.

---

## Summary

### Cryptography

Protects data using mathematics.

### Main limitation

Strong mathematics can still be defeated by weak implementation.

### Standards

Publicly reviewed algorithms such as AES and SHA-3 are safer than custom designs.

### Complexity

More complexity usually creates more security weaknesses.

### Real-world security

Depends on:

* Algorithms
* Software
* Hardware
* Users
* Networks
* Configuration
* Randomness
* Key management
* Ongoing maintenance

### Core idea

> Do not try to outsmart decades of cryptographic research.

Use simple designs, trusted standards, secure libraries, and correct implementation.

Attackers usually do not break the cryptography.

They find where developers used it incorrectly.

```
```
