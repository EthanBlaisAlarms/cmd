<html>
  <body>
    <?php
    $time = date("h:i:sa m/d/Y")
    $subject = $_POST["subject"];
    $msg ="From: $_POST["email"] ($_POST["name"])\nTime: $time\nMessage: $_POST["description"]";
    mail("ethanblaisalarms@gmail.com","Contact You - $subject",$msg);
    echo "Submitted!";
    ?>
  </body>
</html>
