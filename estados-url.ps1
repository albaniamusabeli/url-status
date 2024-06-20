# Ruta del archivo de entrada (txt)
$archivoEntrada = "C:\Users\Albania\PROYECTOS\POWERSHELL\url-status\urls.txt"

# Obtener la fecha y hora actual
$fechaHora = Get-Date -Format "yyyyMMdd_HHmmss"

# SMTP Config
$smtp_host = "smtp.office365.com"
$smtp_port = 587
$smtp_ssl = $true
$smtp_user = "noreply@hqbdoc.cl"
$smtp_pass = "XdpNOREPLY.,2019"
##$smtp_recipients = "Albania Musabeli <albania.musabeli@hqb.cl>"
$smtp_recipients = "Albania Musabeli <vero.musabeli7@gmail.com>"
$smtp_subject = "Reporte de estados de sitios web HQB Produccion $current_datetime_email"

# Nombre del archivo de log resultante con la fecha y hora
$nombreArchivoLog = "estados_urls_$fechaHora.csv"
$archivoSalida = "C:\Users\Albania\PROYECTOS\POWERSHELL\url-status\$nombreArchivoLog"

# Leer el archivo de entrada y obtener las URL
$urlList = Get-Content -Path $archivoEntrada

# Crear un array para almacenar los resultados
$resultados = @()

# Función envio de correo
function SendEmail($recipients, $recipients_copy, $subject, $body, $attachment) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $smtp = New-Object Net.Mail.SmtpClient($smtp_host, $smtp_port)
    $smtp.EnableSsl = $true
    $smtp.Credentials = New-Object Net.NetworkCredential($smtp_user, $smtp_pass)

    $mail = New-Object Net.Mail.MailMessage
    $mail.From = $smtp_user
    $mail.To.Add($recipients)
    if ($recipients_copy -ne $null) {
        $mail.CC.Add($recipients_copy)
    }
    $mail.Subject = $subject
    $mail.Body = $body

    if ($attachment -ne $null)
    {
        $file_attachment = New-Object Net.Mail.Attachment $attachment
        $mail.Attachments.Add($file_attachment)
    }

    $smtp.Send($mail)
    $smtp.Dispose()

    $mail.Dispose()
}



# Realizar la comprobación de cada URL
foreach ($url in $urlList) {
    $status = ""
    $code = 0
    try {
        # Crear una solicitud HTTP
        $request = Invoke-WebRequest -Uri $url -Method Head -ErrorAction Stop
        
        # Verificar el estado de la respuesta
        if ($request.StatusCode -eq 200) {
            $code = $request.StatusCode
            $status = "Operativa"
        } else {
            $status = "No operativa"
        }
    } catch {
        $status = "No se pudo obtener el estado"
    }
    
    # Crear un objeto $resultado y agregar la URL, el numero de codigo y el estado
    $resultado = [PSCustomObject]@{
        URL = $url
        Codigo = $code
        Estado = $status
    }
    $resultados += $resultado

    # Registrar el análisis de la URL en la terminal
    Write-Host "URL analizada: $url"
}

# Exportar los resultados al archivo CSV
$resultados | Export-Csv -Path $archivoSalida -NoTypeInformation

# Enviar el correo con el archivo adjunto
$correoBody = "Proceso completado. Se adjunta archivo CSV con los resultados del analisis: $archivoSalida"
SendEmail -recipients $smtp_recipients -subject $smtp_subject -body $correoBody -attachment $archivoSalida

Write-Host "Proceso completado. Los resultados se han guardado en: $archivoSalida"