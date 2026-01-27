# Dummy Test Accounts

This document contains test credentials for the authentication flow.

## 🧑 Regular Users (Customers)

Use these credentials to login as a regular customer:

| Name | Email | OTP |
|------|-------|-----|
| John Doe | john@example.com | `111111` |
| Jane Smith | jane@example.com | `222222` |
| Bob Johnson | bob@example.com | `333333` |

## 👷 Service Boys (Service Providers)

Use these credentials to login as a service provider:

| Name | Email | OTP |
|------|-------|-----|
| Mike Williams | mike@service.com | `999999` |
| Tom Brown | tom@service.com | `888888` |
| Sam Davis | sam@service.com | `777777` |

## 🔐 How to Test

1. **Open the app** and navigate to the login screen
2. **Select user type**: 
   - Tap "User" for regular customers
   - Tap "Service Boy" for service providers
3. **Enter email**: Use any email from the table above matching your selected user type
4. **Enter any password**: Password validation is basic (minimum 6 characters)
5. **Click "Sign In"**: You'll be navigated to the OTP screen
6. **Enter OTP**: The correct OTP is displayed on the OTP screen for testing purposes
   - You can also see it in the table above
7. **Verify**: Upon successful verification, you'll be logged in!

## 📝 Notes

- The OTP hint is displayed on the OTP verification screen for testing convenience
- In production, this hint would be removed
- Each user type has different OTPs to demonstrate the separation
- Invalid email/user type combinations will show an error message
