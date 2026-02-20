# Quick Test Guide - Medication Alarm System

## Prerequisites
1. Flutter app installed on device/emulator
2. Firebase configured and connected
3. Notification permissions granted

## Test 1: Tap-to-Confirm Feature (5 minutes)

### Setup:
1. Login as clinician
2. Select/create a patient
3. Prescribe medication:
   - Name: "Test Medicine"
   - Dosage: "500mg"
   - Frequency: "Three times daily"
   - Times: Enter current time + 2 minutes, current time + 4 hours, current time + 8 hours
   - Start Date: Today
   - End Date: Today + 3 days

### Test Steps:
1. Logout and login as the patient
2. Wait 2 minutes for the first dose time
3. You should see an ORANGE card that says "TAP TO CONFIRM"
4. Tap the card
5. Verify:
   - ✅ Card turns GREEN with "Taken" status
   - ✅ Success message appears
   - ✅ Next dose time is shown

### Expected Result:
- Orange card appears at scheduled time
- Tapping confirms the dose
- Visual feedback changes immediately
- Data syncs to clinician dashboard

---

## Test 2: Notification Reminders (2 minutes)

### Setup:
1. Ensure notifications are enabled
2. Close the app completely
3. Wait for scheduled dose time

### Test Steps:
1. Wait for notification to appear
2. Tap notification
3. App opens to home screen
4. Confirm dose by tapping orange card

### Expected Result:
- ✅ Notification appears at exact scheduled time
- ✅ Notification shows medication name and dosage
- ✅ Tapping notification opens app
- ✅ Can confirm dose from notification

---

## Test 3: Missed Dose Indicator (3 minutes)

### Setup:
1. Prescribe medication with time 1 hour in the past
2. Refresh patient home screen

### Test Steps:
1. Look at medication schedule
2. Find the past dose time

### Expected Result:
- ✅ Past dose shows RED "Missed" status
- ✅ Cannot tap to confirm (time has passed)
- ✅ Future doses still show as scheduled

---

## Test 4: Auto-Expiry After Duration (Overnight Test)

### Setup:
1. Prescribe medication:
   - Start Date: Today
   - End Date: Today (same day)
   - Times: Any time

### Test Steps:
1. Wait until next day (or change device date to tomorrow)
2. Login as patient
3. Check home screen

### Expected Result:
- ✅ Medication no longer appears in active list
- ✅ Notification shows "1 medication(s) have expired"
- ✅ No more notifications scheduled

### Verify on Clinician Dashboard:
1. Login as clinician
2. Select the patient
3. Check medications list

### Expected Result:
- ✅ Expired medication not shown in active medications
- ✅ Historical adherence data still available
- ✅ Can view past dose logs

---

## Test 5: Clinician Dashboard Sync (2 minutes)

### Setup:
1. Have patient confirm 2 doses and miss 1 dose
2. Login as clinician

### Test Steps:
1. Navigate to clinician dashboard
2. Select the patient
3. View adherence card

### Expected Result:
- ✅ Adherence shows ~67% (2 taken / 3 scheduled)
- ✅ Can see which doses were taken
- ✅ Can see which doses were missed
- ✅ Real-time updates as patient confirms doses

---

## Quick Verification Checklist

### Patient Side:
- [ ] Receives notifications at scheduled times
- [ ] Can tap orange card to confirm dose
- [ ] Sees green "Taken" status after confirmation
- [ ] Sees red "Missed" for past doses
- [ ] Expired medications disappear automatically

### Clinician Side:
- [ ] Can prescribe medications with specific times
- [ ] Sees only active medications for patients
- [ ] Views accurate adherence percentages
- [ ] Expired medications auto-removed from dashboard
- [ ] Can view historical dose logs

---

## Common Issues & Solutions

### Issue: Notifications not appearing
**Solution**: 
- Go to device Settings > Apps > DawaTrack > Notifications
- Enable all notification permissions
- Disable battery optimization for the app

### Issue: Tap not working
**Solution**:
- Ensure current time is within 30 minutes of scheduled time
- Check if dose was already confirmed
- Verify internet connection

### Issue: Medication not expiring
**Solution**:
- Close and reopen the app
- Check end date is set correctly
- Verify device date/time is correct

---

## Demo Script (For Presentation)

**"Let me show you the core feature of DawaTrack - the medication reminder system."**

1. **Show Prescription** (30 seconds)
   - "As a clinician, I prescribe medication for 3 days with specific times"
   - Show prescribe screen with times: 8:00 AM, 2:00 PM, 8:00 PM

2. **Show Patient View** (1 minute)
   - "The patient sees their medication schedule"
   - Point out the orange "TAP TO CONFIRM" card
   - "When it's time to take medication, they simply tap this card"
   - Tap and show green confirmation

3. **Show Adherence** (30 seconds)
   - "The clinician can monitor adherence in real-time"
   - Show dashboard with adherence percentage
   - "They can see exactly which doses were taken or missed"

4. **Show Auto-Expiry** (30 seconds)
   - "After 3 days, the medication automatically expires"
   - Show empty medication list
   - "No more reminders, clean dashboard"

**Total Demo Time: 2.5 minutes**
