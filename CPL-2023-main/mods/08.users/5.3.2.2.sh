#!/usr/bin/env bash
{
    arr=('Name: Enable pam_faillock to deny access'
         'Default: yes'
         'Priority: 0'
         'Auth-Type: Primary'
         'Auth:'
         ' [default=die] pam_faillock.so authfail')
    printf '%s\n' "${arr[@]}" > /usr/share/pam-configs/faillock
}

{
    arr=('Name: Notify of failed login attempts and reset count upon success'
         'Default: yes'
         'Priority: 1024'
         'Auth-Type: Primary'
         'Auth:'
         ' requisite pam_faillock.so preauth'
         'Account-Type: Primary'
         'Account:'
         ' required pam_faillock.so')
    printf '%s\n' "${arr[@]}" > /usr/share/pam-configs/faillock_notify
}

