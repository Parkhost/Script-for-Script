$inputXML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    xmlns:local="clr-namespace:Tab_Me_baby_one_more_time"
    mc:Ignorable="d"
    Title="Alert Task Schedule" Height="520" Width="750.256">
    <Grid>
        <Label Content="Scheduled task has been created or edited" HorizontalAlignment="Left" Margin="97,44,0,0" VerticalAlignment="Top" Width="262"/>
        <Label Content="Date:" HorizontalAlignment="Left" Margin="28,121,0,0" VerticalAlignment="Top" Width="141"/>
        <Label Content="TaskName:" HorizontalAlignment="Left" Margin="28,152,0,0" VerticalAlignment="Top" Width="141"/>
        <Label Content="State:" HorizontalAlignment="Left" Margin="28,178,0,0" VerticalAlignment="Top" Width="141"/>
        <Label Content="Execute:" HorizontalAlignment="Left" Margin="28,204,0,0" VerticalAlignment="Top" Width="141"/>
        <Label Content="Arguments:" HorizontalAlignment="Left" Margin="28,237,0,0" VerticalAlignment="Top" Width="141"/>
        <Label Content="Event ID:" HorizontalAlignment="Left" Margin="28,268,0,0" VerticalAlignment="Top" Width="141"/>
        <Label Content="Proces:" HorizontalAlignment="Left" Margin="28,299,0,0" VerticalAlignment="Top" Width="141"/>
        <TextBox x:Name="Date" HorizontalAlignment="Left" Height="23" Margin="174,121,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="332"/>
        <TextBox x:Name="TaskName" HorizontalAlignment="Left" Height="23" Margin="174,152,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="332"/>
        <TextBox x:Name="State" HorizontalAlignment="Left" Height="23" Margin="174,178,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="332"/>
        <TextBox x:Name="Execute" HorizontalAlignment="Left" Height="23" Margin="174,204,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="332"/>
        <TextBox x:Name="Arguments" HorizontalAlignment="Left" Height="23" Margin="174,241,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="332"/>
        <TextBox x:Name="Event_ID" HorizontalAlignment="Left" Height="23" Margin="174,271,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="332"/>
        <TextBox x:Name="Proces" HorizontalAlignment="Left" Height="23" Margin="174,302,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="332"/>
        <Button x:Name="Block" Content="Block" HorizontalAlignment="Left" Margin="454,393,0,0" VerticalAlignment="Top" Width="75" RenderTransformOrigin="0.227,-0.6"/>
        <Button x:Name="Unblock" Content="Unblock" HorizontalAlignment="Left" Margin="359,393,0,0" VerticalAlignment="Top" Width="75" RenderTransformOrigin="0.227,-0.6"/>
    </Grid>
</Window>
"@ 
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $Form = [Windows.Markup.XamlReader]::Load( $reader )
}
catch {
    Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
    throw
}
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
  
$xaml.SelectNodes("//*[@Name]") | % { "trying item $($_.Name)";
    try {
        Set-Variable –Name "WPF$($_.Name)" –Value $Form.FindName($_.Name) –ErrorAction Stop
    }
    catch { throw $_ }
}
 
# Function Get-FormVariables {
#     if ($global:ReadmeDisplay -ne $true) { Write-host "If you need to reference this display again, run Get-FormVariables" –ForegroundColor Yellow; $global:ReadmeDisplay = $true }
#     write-host "Found the following interactable elements from our form" –ForegroundColor Cyan
#     get-variable WPF*
# }
 
# Get-FormVariables
 
#===========================================================================
# Use this space to add code to the various form elements in your GUI
#===========================================================================

#$WPFDate.Text = $result.Date
#$WPFTaskName.Text = $result.TaskName
#$WPFState.Text = $result.State
#$WPFExecute.Text = $result.Execute
#$WPFArguments.Text = $result.Arguments
#$WPFEvent_ID.Text = $result.ID
#$WPFProces.Text = $result.failed


                                                                    
$WPFUnblock.Add_Click( { Write-host 'unblock' })
$WPFblock.Add_Click( { Write-host 'block' })
#===========================================================================
# Shows the form
#===========================================================================
write-host "To show the form, run the following" –ForegroundColor Cyan
$Form.ShowDialog() | out-null