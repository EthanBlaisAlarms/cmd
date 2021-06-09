var os = navigator.appVersion
var compatible = "Your operating system was not recognized: " + os
var isComp = 1
if (os.indexOf("X11") != -1) {
  compatible = "Your OS was detected as Ubuntu, which doesnt support EBA Command Center."
  isComp = 0
}
if (os.indexOf("Windows") != -1) {
  compatible = "Your OS was detected as Microsoft Windows."
  isComp = 1
  if (os.indexOf("Windows NT 10") != -1) {
    compatible = "EBA Command Center is compatible with your PC which runs Microsoft Windows 10."
    isComp = 2
  }
  if (os.indexOf("Windows NT 8") != -1) {
    compatible = "EBA Command Center is compatible with your PC which runs Microsoft Windows 8."
    isComp = 2
  }
  if (os.indexOf("Windows NT 7") != -1) {
    compatible = "EBA Command Center is compatible with your PC which runs Microsoft Windows 7."
    isComp = 2
  }
  if (os.indexOf("Windows NT Vista") != -1) {
    compatible = "EBA Command Center is compatible with your PC which runs Microsoft Windows Vista."
    isComp = 2
  }
  if (os.indexOf("Windows NT XP") != -1) {
    compatible = "Your OS was detected as Microsoft Windows XP, which doesnt support EBA Command Center."
    isComp = 0
  }
}
if (os.indexOf("Mac") != -1) {
  compatible = "Your OS was detected as Apple MacOS, which doesnt support EBA Command Center."
  isComp = 0
}
if (os.indexOf("iPhone") != -1) {
  compatible = "Your device was detected as Apple iPhone, which doesnt support EBA Command Center."
}
if (os.indexOf("Linux") != -1) {
  compatible = "Your OS was detected as Linux, which doesnt support EBA Command Center."
  isComp = 0
}
if (os.indexOf("CrOS") != -1) {
  compatible = "Your OS was detected as Google ChromeOS_Linux, which doesnt support EBA Command Center."
  isComp = 0
}
if (os.indexOf("Android") != -1) {
  compatible = "Your device was detected as Android_Linux, which doesnt support EBA Command Center."
  isComp = 0
}
if (os.indexOf("SMART-TV") != -1) {
  compatible = "Your device was detected as Samsung SmartTV_Linux, which doesnt support EBA Command Center."
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
