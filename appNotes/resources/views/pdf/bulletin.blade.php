<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <title>Bulletin</title>
  <style>
    body { font-family: DejaVu Sans, Arial, sans-serif; font-size: 12px; }
    h1 { font-size: 18px; margin: 0 0 10px; }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border: 1px solid #333; padding: 6px; text-align: left; }
    .meta { margin-bottom: 10px; }
  </style>
</head>
<body>
  <h1>Bulletin de notes</h1>
  <div class="meta">
    <div><strong>Nom:</strong> {{ $student->last_name }} {{ $student->first_name }}</div>
    <div><strong>Email:</strong> {{ $student->email }}</div>
    <div><strong>Matricule:</strong> {{ $student->matricule }}</div>
    <div><strong>Filière:</strong> {{ $student->filiere }}</div>
  </div>
  <table>
    <thead>
      <tr>
        <th>Matière</th>
        <th>Coefficient</th>
        <th>Note /20</th>
      </tr>
    </thead>
    <tbody>
      @foreach($grades as $g)
        <tr>
          <td>{{ $g->subject->name ?? '-' }}</td>
          <td>{{ $g->subject->coefficient ?? 1 }}</td>
          <td>{{ number_format((float)$g->score, 2) }}</td>
        </tr>
      @endforeach
    </tbody>
  </table>
  <p style="margin-top: 10px;"><strong>Moyenne générale:</strong> {{ $average !== null ? number_format($average, 2) : '-' }}</p>
</body>
</html>
