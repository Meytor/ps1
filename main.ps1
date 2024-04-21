Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
# Ruta absoluta de la imagen
$playersprite = Join-Path -Path $PSScriptRoot -ChildPath ".\pgif.gif"
# Ruta absoluta de la imagen
$salsasprite = Join-Path -Path $PSScriptRoot -ChildPath ".\salsa.png"
# Ruta absoluta de la posicion del jugador
$absoluteCoordsPath = Join-Path -Path $PSScriptRoot -ChildPath ".\posicion.txt"
# Ruta de la imagen de fondo
$background = Join-Path -Path $PSScriptRoot -ChildPath "explain.gif"  # Ajusta la ruta de la imagen según tu ubicación

# Crear una ventana
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "PS1 SinglePlayer"
$Form.Size = New-Object System.Drawing.Size(600, 600)
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle  # Fija el tamaño de la ventana
$Form.MaximizeBox = $false  # Desactiva el botón maximizar

# Calcular la posición para centrar la ventana
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$left = ($screen.Width - $Form.Width) / 2
$top = ($screen.Height - $Form.Height) / 2
$Form.StartPosition = "Manual"
$Form.Location = New-Object System.Drawing.Point($left, $top)

# Crear un control PictureBox para mostrar el fondo GIF
$fondoPictureBox = New-Object System.Windows.Forms.PictureBox
$fondoPictureBox.Size = $form.ClientSize
$fondoPictureBox.Location = New-Object System.Drawing.Point(0, 0)
$fondoPictureBox.SizeMode = "StretchImage"  # Ajustar el modo de visualización para que la imagen se ajuste al control
$fondoPictureBox.Image = [System.Drawing.Image]::FromFile($background)

# Añadir el control PictureBox al formulario
# Mover el fondo GIF al fondo


###### salsa

# Función para verificar la colisión entre dos PictureBox
function CheckCollision {
    param($pb1, $pb2)
    # Obtener los rectángulos delimitadores de los PictureBox
    $rect1 = $pb1.Bounds
    $rect2 = $pb2.Bounds

    # Verificar si los rectángulos se superponen
    if ($rect1.IntersectsWith($rect2)) {
        return $true  # Colisión detectada
    } else {
        return $false  # No hay colisión
    }
}
# Crear un PictureBox para el objetivo
$Objective = New-Object System.Windows.Forms.PictureBox
$Objective.Size = New-Object System.Drawing.Size(20, 53)
$Objective.Image = [System.Drawing.Image]::FromFile($salsasprite)
$Objective.BackColor = [System.Drawing.Color]::Transparent
$Objective.Location = New-Object System.Drawing.Point(150, 100)

# funcion de puntos

function SumarPuntos {
    param(
        [ref]$Puntos
    )
    # Sumar 1 al valor de la variable $Puntos
    $Puntos.Value++
}

# Inicializar la variable de puntos
$Puntos = [ref]0
# Llamar a la función para sumar puntos y actualizar la variable
SumarPuntos -Puntos $Puntos
# Imprimir el resultado
Write-Host "Puntos despues de sumar: $($Puntos.Value)"

############ player sprite

# Crear un PictureBox para mostrar la imagen de el jugador
$PictureBox = New-Object System.Windows.Forms.PictureBox
$PictureBox.Size = New-Object System.Drawing.Size(28, 60)
$PictureBox.Location = New-Object System.Drawing.Point(260, 230)
$PictureBox.Image = [System.Drawing.Image]::FromFile($playersprite)

# Cargar la imagen del jugador con fondo transparente
$playerImage = [System.Drawing.Image]::FromFile($playersprite)
# Configurar el control PictureBox para que el fondo sea transparente
$PictureBox.BackColor = [System.Drawing.Color]::Transparent
$PictureBox.BackgroundImage = $playerImage
$PictureBox.BackgroundImageLayout = "None"  # Establecer el modo de diseño de la imagen a None para evitar que se estire

############ Crear una etiqueta para mostrar las coordenadas

$Label = New-Object System.Windows.Forms.Label
$Label.AutoSize = $true
$Label.Location = New-Object System.Drawing.Point(10, 10)


############# SE AÑADEN LAS IMAGENES A EL FORM

$Form.Controls.Add($Label)
$Form.Controls.Add($PictureBox)
$Form.Controls.Add($Objective)
$form.Controls.Add($fondoPictureBox)



# Variable para controlar el movimiento horizontal y vertical
$MoveX = 0
$MoveY = 0

# Funcion para actualizar la variable $MoveX y $MoveY cuando se presionan y sueltan las teclas de flecha
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

# Funcion para actualizar la posicion del jugador y guardarla en un archivo
function UpdatePlayerPosition {
    $newX = $PictureBox.Left + ($MoveX * 5)  # Multiplicamos por 5 para ajustar la velocidad
    $newY = $PictureBox.Top + ($MoveY * 5)  # Multiplicamos por 5 para ajustar la velocidad
    $PictureBox.Location = New-Object System.Drawing.Point($newX, $newY)

    # Verificar colisión
    if (CheckCollision $PictureBox $Objective) {
        SumarPuntos -Puntos $Puntos
        # Imprimir el resultado
        Write-Host "Puntos despues de sumar: $($Puntos.Value)"
        $Label.Text = $Puntos.Value
        # Obtener los límites para la posición aleatoria dentro de los límites del formulario
        $smaxX = $Form.Width - $Objective.Width
        $smaxY = $Form.Height - $Objective.Height
        # Generar una posición aleatoria dentro de los límites del formulario
        $snewX = Get-Random -Minimum 0 -Maximum $smaxX
        $snewY = Get-Random -Minimum 0 -Maximum $smaxY
        # Establecer la nueva ubicación del objeto
        $Objective.Location = New-Object System.Drawing.Point($snewX, $snewY)
    }
    
    # Guardar la posicion en el archivo de texto
    $position = "X: $newX, Y: $newY"
    $position | Out-File -FilePath $absoluteCoordsPath -Encoding utf8
}
# Crea un temporizador para actualizar la posicion del jugador periodicamente
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 50  # Intervalo de actualizacion en milisegundos (ajustable segon la velocidad deseada)
$timer.Add_Tick({
    UpdatePlayerPosition
})
$timer.Start()

# Muestra el formulario
$form.ShowDialog() | Out-Null
