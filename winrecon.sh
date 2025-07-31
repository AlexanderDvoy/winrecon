#!/bin/bash

# WinRecon - Complete Windows Recon Tool by Alex


TARGET="10.100.102.9"
USER="alxanderpc"
DATE=$(date +%Y-%m-%d_%H%M)
OUTDIR="winrecon_${TARGET}_${DATE}"

mkdir -p "$OUTDIR"

echo "[*] Starting WinRecon scan on $TARGET"
echo "[*] Results will be saved in $OUTDIR"
echo

# 1. Ping test
echo "[*] Pinging $TARGET..."
ping -c 3 $TARGET | tee "$OUTDIR/ping.txt"

# 2. Nmap top 1000 ports scan
echo -e "\n[*] Running Nmap top 1000 ports scan..."
nmap -sS -Pn --top-ports 1000 -T4 $TARGET -oN "$OUTDIR/nmap_top1000.txt"

# 3. SMB anonymous shares
echo -e "\n[*] Checking SMB shares (anonymous)..."
smbclient -L //$TARGET -N | tee "$OUTDIR/smb_shares_anonymous.txt"

# 4. SMB shares with username (empty password)
echo -e "\n[*] Checking SMB shares with user: $USER (empty password)..."
smbclient -L //$TARGET -U "$USER%" 2>/dev/null | tee "$OUTDIR/smb_shares_user.txt"

# 5. CrackMapExec unauthenticated scan
echo -e "\n[*] CrackMapExec SMB scan (unauthenticated)..."
crackmapexec smb $TARGET | tee "$OUTDIR/cme_anon.txt"

# 6. CrackMapExec authenticated scan (empty password)
echo -e "\n[*] CrackMapExec SMB scan with user: $USER (empty password)..."
crackmapexec smb $TARGET -u "$USER" -p "" | tee "$OUTDIR/cme_user.txt"

# 7. Nmap scan common Windows services
echo -e "\n[*] Scanning RDP (3389), WinRM (5985), HTTP (80,443)..."
nmap -p 3389,5985,80,443 $TARGET -sV -oN "$OUTDIR/nmap_services.txt"

# 8. Check SMB signing (security check)
echo -e "\n[*] Checking SMB signing status (important security check)..."
crackmapexec smb $TARGET --shares | tee "$OUTDIR/smb_signing_check.txt"

# 9. Firewall ACK scan
echo -e "\n[*] Scanning ports 135,139,445 with TCP ACK to detect firewall..."
nmap -sA -p 135,139,445 $TARGET -oN "$OUTDIR/nmap_firewall_ack.txt"

# 10. Firewall bypass script scan
echo -e "\n[*] Running Nmap firewall-bypass script scan on ports 135,139,445..."
nmap -Pn -p 135,139,445 --script=firewall-bypass $TARGET -oN "$OUTDIR/nmap_firewall_bypass.txt"

echo -e "\n✅ Scan complete. All outputs saved to $OUTDIR"
