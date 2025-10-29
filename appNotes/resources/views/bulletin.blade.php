<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Bulletin de Notes</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .student-info { margin-bottom: 20px; }
        .grades-table { width: 100%; border-collapse: collapse; }
        .grades-table th, .grades-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .grades-table th { background-color: #f2f2f2; }
        .footer { margin-top: 30px; text-align: center; }
    </style>
</head>
<body>
    <div class="header">
        <h1>BULLETIN DE NOTES</h1>
        <h2>Université - Gestion des Notes</h2>
    </div>
    
    <div class="student-info">
        <p><strong>Nom:</strong> {{ $user->name }}</p>
        <p><strong>Matricule:</strong> {{ $student->matricule }}</p>
        <p><strong>Filière:</strong> {{ $student->filiere }}</p>
        <p><strong>Date:</strong> {{ date('d/m/Y') }}</p>
    </div>
    
    <table class="grades-table">
        <thead>
            <tr>
                <th>Matière</th>
                <th>Code</th>
                <th>Note</th>
                <th>Coefficient</th>
                <th>Semestre</th>
            </tr>
        </thead>
        <tbody>
            @foreach($grades as $grade)
            <tr>
                <td>{{ $grade->course->name }}</td>
                <td>{{ $grade->course->code }}</td>
                <td>{{ $grade->note }}/20</td>
                <td>{{ $grade->course->coefficient }}</td>
                <td>{{ $grade->semestre }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>
    
    <div class="footer">
        <p><strong>Moyenne générale:</strong> {{ number_format($moyenne, 2) }}/20</p>
        <p>Bulletin généré le {{ date('d/m/Y à H:i') }}</p>
    </div>
</body>
</html>