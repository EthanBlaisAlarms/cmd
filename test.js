function alert() {
  var eba;
  var unlocked = false;
  while (unlocked = false) {
    eba = prompt("Enter password:","PASSWORD");
    if (eba === 'Dexter05-') {
      alert("Correct password...");
      unlocked = true;
    } else {
      alert("Wrong password. Try again.");
    }
  }
}

alert();
