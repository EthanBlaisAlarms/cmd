var os = navigator.appVersion
var compatible = "Your operating system was not recognized: " + os
var isComp = 1
if (os.indexOf("X11") != -1) {
  compatible = "Your OS was detected as Linux, which doesnt support EBA Cmd."
  isComp = 0
}
if (os.indexOf("Windows") != -1) {
  compatible = "Your OS was detected as Windows, but we couldnt get your Windows version."
  if (os.indexOf("Windows NT 10") != -1) {
    compatible = "Your Windows 10 PC is compatible with EBA Command Center!"
    isComp = 2
  }
  if (os.indexOf("Windows NT 8.1") != -1) {
    compatible = "Your Windows 8.1 PC is compatible with EBA Command Center!"
    isComp = 2
  }
  if (os.indexOf("Windows NT 8") != -1) {
    compatible = "Your Windows 8 PC is compatible with EBA Command Center!"
    isComp = 2
  }
  if (os.indexOf("Windows NT 7") != -1) {
    compatible = "Your Windows 7 PC is compatible with EBA Command Center!"
    isComp = 2
  }
  if (os.indexOf("Windows NT Vista") != -1) {
    compatible = "Your Windows Vista PC might run into a few problems running EBA Command Center."
    isComp = 1
  }
  if (os.indexOf("Windows NT XP") != -1) {
    compatible = "Sorry! EBA Command Center will not run properly on your Windows XP PC."
    isComp = 0
  }
}
if (os.indexOf("Mac") != -1) {
  compatible = "Sorry! EBA Command Center will not run properly on your MacOS PC."
  isComp = 0
}
if (os.indexOf("iPhone") != -1) {
  compatible = "Sorry! EBA Command Center will not run properly on your iPhone."
}
if (os.indexOf("Linux") != -1) {
  compatible = "Sorry! EBA Command Center will not run properly on your Linux device."
  isComp = 0
}
if (os.indexOf("CrOS") != -1) {
  compatible = "Sorry! EBA Command Center will not run properly on your Linux(ChromeOS) PC."
  isComp = 0
}
if (os.indexOf("Android") != -1) {
  compatible = "Sorry! EBA Command Center will not run properly on your Linux(Android) device."
  isComp = 0
}
if (os.indexOf("SMART-TV") != -1) {
  compatible = "Sorry! EBA Command Center will not run properly on your Linux(Samsung TV)."
  isComp = 0
}
//Display
if (isComp === 0) {
  document.getElementById("OSRed").innerHTML = compatible
}
if (isComp === 1) {
  document.getElementById("OSYellow").innerHTML = compatible
}
if (isComp === 2) {
  document.getElementById("OSGreen").innerHTML = compatible
}
