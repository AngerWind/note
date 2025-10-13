{{/*
Return full name for module
*/}}
{{- define "myapp.fullname" -}}
{{- printf "%s-%s" .Chart.Name . | trunc 63 | trimSuffix "-" -}}
{{- end }}
