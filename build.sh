#!/bin/sh

cp -r assets/ build/

elm make src/Main.elm --optimize --output=build/main.js

cat <<EOF > build/index.html
<!DOCTYPE HTML>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<div id="content"></div>
<script type="text/javascript">
$(cat build/main.js)
var app = Elm.Main.init({
                            node: document.getElementById("content"),
                            flags: {
                                width: window.innerWidth,
                                height: window.innerHeight
                            }
                        });
</script>
</body>
</html>
EOF


