<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ config('app.name', 'appNotes') }}</title>
    @vite(['resources/css/app.css','resources/js/app.js'])
</head>
<body>
<div id="app"></div>
</body>
</html>
