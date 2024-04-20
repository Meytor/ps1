Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Ruta relativa de la imagen
$imagePath = ".\player.png"

# Ruta absoluta de la imagen
$absoluteImagePath = Join-Path -Path $PSScriptRoot -ChildPath $imagePath

# Ruta del archivo de texto para guardar la posición del jugador
$positionFilePath = ".\posicion.txt"

# Ruta absoluta de la posicion del jugador
$absoluteCoordsPath = Join-Path -Path $PSScriptRoot -ChildPath $positionFilePath

# Crear una ventana
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Mover Imagen con Flechas"
$Form.Size = New-Object System.Drawing.Size(400, 300)

# Crear un PictureBox para mostrar la imagen
$PictureBox = New-Object System.Windows.Forms.PictureBox
$PictureBox.Size = New-Object System.Drawing.Size(100, 100)
$PictureBox.Location = New-Object System.Drawing.Point(50, 50)
$PictureBox.Image = [System.Drawing.Image]::FromFile($absoluteImagePath)
$Form.Controls.Add($PictureBox)



# Variable para controlar el movimiento horizontal y vertical
$MoveX = 0
$MoveY = 0

# Función para actualizar la variable $MoveX y $MoveY cuando se presionan y sueltan las teclas de flecha
function UpdateMovement {
    param($keyCode, $pressed)
    if ($keyCode -eq [System.Windows.Forms.Keys]::Left) {
        $global:MoveX = if ($pressed) { -1 } else { 0 }
    } elseif ($keyCode -eq [System.Windows.Forms.Keys]::Right) {
        $global:MoveX = if ($pressed) { 1 } else { 0 }
    } elseif ($keyCode -eq [System.Windows.Forms.Keys]::Up) {
        $global:MoveY = if ($pressed) { -1 } else { 0 }
    } elseif ($keyCode -eq [System.Windows.Forms.Keys]::Down) {
        $global:MoveY = if ($pressed) { 1 } else { 0 }
    }
}

# Evento KeyDown para detectar cuando se presionan las teclas de flecha
$form.Add_KeyDown({
    param($sender, $e)
    UpdateMovement $e.KeyCode $true
})

# Evento KeyUp para detectar cuando se sueltan las teclas de flecha
$form.Add_KeyUp({
    param($sender, $e)
    UpdateMovement $e.KeyCode $false
})

# Función para actualizar la posición del jugador y guardarla en un archivo
function UpdatePlayerPosition {
    $newX = $PictureBox.Left + ($MoveX * 5)  # Multiplicamos por 5 para ajustar la velocidad
    $newY = $PictureBox.Top + ($MoveY * 5)  # Multiplicamos por 5 para ajustar la velocidad
    $PictureBox.Location = New-Object System.Drawing.Point($newX, $newY)

    # Guardar la posición en el archivo de texto
    $position = "X: $newX, Y: $newY"
    $position | Out-File -FilePath $absoluteCoordsPath -Encoding utf8
}

# Crea un temporizador para actualizar la posición del jugador periódicamente
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 50  # Intervalo de actualización en milisegundos (ajustable según la velocidad deseada)
$timer.Add_Tick({
    UpdatePlayerPosition
})
$timer.Start()

# Muestra el formulario
$form.ShowDialog() | Out-Null




