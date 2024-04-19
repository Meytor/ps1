# Función para escribir un carácter en una posición específica en la consola
function Write-CharAtPosition {
    param(
        [string]$char,
        [string]$char2,
        [int]$x,
        [int]$y
    )
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $x, $y
    Write-Host -NoNewline $char
}

# Función para guardar las coordenadas en un archivo
function GuardarCoordenadas {
    $coordenadas = "$x,$y"
    $coordenadas | Out-File -FilePath "coordenadas.txt"
}


# Coordenadas de la posición en la consola
$x = 1
$y = 1


# Carácter a escribir
$char = "O"
$char2 = " "

# Guardar la representación en una variable
$consoleOutput = $char

# Mostrar la variable
$consoleOutput



# FunciÃ³n para capturar la entrada de teclado
Function Get-KeyPress {
    $key = $host.UI.RawUI.ReadKey("IncludeKeyDown,NoEcho").VirtualKeyCode
    return $key
}

# Bucle para detectar la tecla presionada
while ($true) {
    $keyCode = Get-KeyPress
    Write-CharAtPosition -char $char2 -x $x -y $y
    GuardarCoordenadas -x $x -y $y
    switch ($keyCode) {
        37 { $x-- }
        38 { $y--  }
        39 { $x++ }
        40 { $y++ }
        default {  }
    }

    Write-CharAtPosition -char $char -x $x -y $y

}