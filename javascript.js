$(function(){
  $("#header").load("https://ethanblaisalarms.github.io/header.html");
  $("#footer").load("https://ethanblaisalarms.github.io/footer.html");
});
(function(c,l,a,r,i,t,y){
  c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
  t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
  y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
})(window, document, "clarity", "script", "69wj77p43q");
function download(fileDir, name) {
  var a = document.createElement("a");
  a.href = fileDir;
  a.setAttribute("download", name);
  a.click();
}
