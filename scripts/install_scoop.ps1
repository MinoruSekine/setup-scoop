param([switch]$RunAsAdmin)
if ($RunAsAdmin) {
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
} else {
    irm get.scoop.sh | iex
}
