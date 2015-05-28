# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Product.create(id: 26, name: "NSA310S", model_class_name: "NSA310S", asset_file_name: "device_icon_gray_1bay.png", asset_content_type: "image/png", asset_file_size: 2497, asset_updated_at:  "2014-10-04 12:28:07", pairing_file_name: "animate_1bay.gif", pairing_content_type: "image/gif", pairing_file_size: 9711, pairing_updated_at: "2014-10-04 12:28:08")
Product.create(id: 27, name: "NSA320S", model_class_name: "NSA320S", asset_file_name: "device_icon_gray_2bay.png", asset_content_type: "image/png", asset_file_size: 2412, asset_updated_at:  "2014-10-04 12:28:37", pairing_file_name: "animate_2bay.gif", pairing_content_type: "image/gif", pairing_file_size: 10116, pairing_updated_at: "2014-10-04 12:28:37")
Product.create(id: 28, name: "NSA325", model_class_name: "NSA325", asset_file_name: "device_icon_gray_2bay.png", asset_content_type: "image/png", asset_file_size: 2412, asset_updated_at:  "2014-10-04 12:29:05", pairing_file_name: "animate_nsa325.gif", pairing_content_type: "image/gif", pairing_file_size: 12266, pairing_updated_at: "2014-10-04 12:29:06")
Product.create(id: 29, name: "NSA325 v2", model_class_name: "NSA325 v2", asset_file_name: "device_icon_gray_2bay.png", asset_content_type: "image/png", asset_file_size: 2412, asset_updated_at:  "2014-10-04 12:29:41", pairing_file_name: "animate_2bay.gif", pairing_content_type: "image/gif", pairing_file_size: 10116, pairing_updated_at: "2014-10-04 12:29:41")
Product.create(id: 30, name: "NAS540", model_class_name: "NAS540", asset_file_name: "device_icon_gray_4bay.png", asset_content_type: "image/png", asset_file_size: 2631, asset_updated_at:  "2014-10-04 12:29:59", pairing_file_name: "animate_4bay.gif", pairing_content_type: "image/gif", pairing_file_size: 9495, pairing_updated_at: "2014-10-04 12:29:59")
Domain.create(domain_name: Settings.environments.ddns)
Api::Certificate.create(serial: "example_serial", content:"-----BEGIN CERTIFICATE-----
MIIGTzCCBDegAwIBAgICEAAwDQYJKoZIhvcNAQELBQAwgbExCzAJBgNVBAYTAlRX
MQ8wDQYDVQQIDAZUYWl3YW4xEDAOBgNVBAcMB0hzaW5DaHUxIjAgBgNVBAoMGVp5
WEVMIGNvbW11bmljYXRpb24gY29ycC4xGzAZBgNVBAsMEkNsb3VkIEFwcGxpYW5j
ZSBCQzEYMBYGA1UEAwwPbXlaeVhFTENsb3VkIENBMSQwIgYJKoZIhvcNAQkBFhVj
bG91ZGFkbUB6eXhlbC5jb20udHcwHhcNMTQxMDE0MDYwMjA5WhcNMTgxMDE0MDYw
MjA5WjCBsDELMAkGA1UEBhMCVFcxDzANBgNVBAgMBlRhaXdhbjEQMA4GA1UEBwwH
SHNpbkNodTEiMCAGA1UECgwZWnlYRUwgY29tbXVuaWNhdGlvbiBjb3JwLjENMAsG
A1UECwwEQ0FCQzElMCMGA1UEAwwcbXlaeVhFTENsb3VkIGludGVybWVkaWF0ZSBD
QTEkMCIGCSqGSIb3DQEJARYVY2xvdWRhZG1Aenl4ZWwuY29tLnR3MIICIjANBgkq
hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA3QNj4mwsBv49Zh7pDi1PDr0/HH9koD0J
2rgLtUcr6vfoHiVrITSjPUMg0dK7ipRCajBbVJ+9Yq9kfs7ocBJjinhWqSrnzNUz
nswqPTSw2aj0Xxau8f60GFmx74qDGPQeVkWWumXCZYdahUJOKADv2rvbcqsggd2p
JE6hACuC7xco9W4Arvf+nNazrZjWwRy2y5hSjPe6IN8Y2gmufwRW8J9nzU1T72ox
jMYbPMN38t2TAMTUIAZ08soRPdSj4Aj2hp/1cn4W7FECyJ3s+DGflHS96YqAPHsi
fnqi/KsqIZ3c5xxCMsfuG7RFz8LNmf/GDxhotwktC965qgNxbr8xTNMreraAfKab
njLaVkpNIVqlICjbZFTvPnwG1pJmnlluO0BkYp6t+f7d3/InQPyAkkiYoWmrj2yX
wVTajWyRGSaD5T6rA/XIctZojrjDhjFoj9cnLBFScJLKTmqPOIOZKSL4uiKvrfqa
YTO3ss8ggKvLceBSRx1dpmA3VwlvO4j5LEuL1S4dlXgyDGm8X/GSUcQ5kaPmqc6f
CvbHuII+cnu+Kjbq18MSo4kjibnl2sfCCG7G2KsXsP5CDFHNWPr7JaOXLp7oumqv
xSRklTwgl8etJBaKV7hV7tc8yEzmjxgbgqnC+H+wfpdQvgd1ZK3esHwEn3OD7zEp
s14uS7Uc17MCAwEAAaNwMG4wHQYDVR0OBBYEFNBx+rl/NYLomZsDoTPHWCkHSH4m
MB8GA1UdIwQYMBaAFO5whKEaDw2m/1Or3EfYXg8K12T6MAwGA1UdEwQFMAMBAf8w
CwYDVR0PBAQDAgEGMBEGCWCGSAGG+EIBAQQEAwIBBjANBgkqhkiG9w0BAQsFAAOC
AgEAG6+F5l8Mru6/R7y18W9H1zFBE6oQU+YiuI5PoUjdkjcKVFHOsgKifsyfJ4J/
bVNvYhkijvDux139c3+JWm/SkxegTvRDl/SVwfe+XjE2wzMjgj/3ZNu/ZL92fAGh
tXUuzkoCV5GzXeVsebgV+HoPkvIzrK+4ezyufyLr9PwuYYw20Ck0xr97IdvWVCbI
gbHSjebUpKJ1/aV19wwpXrgw+VMSTe8Lrpt7WUxOinHBJ/zXrTYBqJyMhiklvDk5
kfB99I3o01FZUuaegG2dnZC76Vtt4oGtkZx9SC/zLT/1coBCXsjPm/R54USfnU0r
UgRKCX8g/s2tho1OHvDmoJyHI53oXEkFavA8lFk2nQfkalvLdKOMl0alApUE0ln2
Lbe0aMOYnSzjXwROXhHa609xM5hDfobi7AxR6anvCZYldog4Hv8P7Mbo+Kx97+op
ZuKh+4dcYPAe2yFn2lPxKGzlZvmw8yspVz3dPiGsKcY/kiAbdMq25mI90JP+/WrE
tIgz6pXx38PwJah89///v9t70AKZCwjjOzm1fUFPMJKFAJD61Ua3iZY1Ek52L1dQ
1nwKx710Ciup7F1PQFUky5JP7MD9HmE+cIbs5Df8rNrgSqjF3uDjASrA9qM91kkF
znf3QDjNYZvULC96M8LxgZzvs/m1+ddXYNJ/lqDz4/3CovA=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIGNzCCBB+gAwIBAgIJALaNxrcjhZtrMA0GCSqGSIb3DQEBCwUAMIGxMQswCQYD
VQQGEwJUVzEPMA0GA1UECAwGVGFpd2FuMRAwDgYDVQQHDAdIc2luQ2h1MSIwIAYD
VQQKDBlaeVhFTCBjb21tdW5pY2F0aW9uIGNvcnAuMRswGQYDVQQLDBJDbG91ZCBB
cHBsaWFuY2UgQkMxGDAWBgNVBAMMD215WnlYRUxDbG91ZCBDQTEkMCIGCSqGSIb3
DQEJARYVY2xvdWRhZG1Aenl4ZWwuY29tLnR3MB4XDTE0MTAxNDA1NDUwMloXDTI0
MTAxMTA1NDUwMlowgbExCzAJBgNVBAYTAlRXMQ8wDQYDVQQIDAZUYWl3YW4xEDAO
BgNVBAcMB0hzaW5DaHUxIjAgBgNVBAoMGVp5WEVMIGNvbW11bmljYXRpb24gY29y
cC4xGzAZBgNVBAsMEkNsb3VkIEFwcGxpYW5jZSBCQzEYMBYGA1UEAwwPbXlaeVhF
TENsb3VkIENBMSQwIgYJKoZIhvcNAQkBFhVjbG91ZGFkbUB6eXhlbC5jb20udHcw
ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCrsc5BAPRrNmTc4l/Mzx5o
DN4o9Qzrz6Vy/P22xEmmXad6QPCu5+hh3rG6LcDnMOHs2R0/BBYpQbXsb08CBU+/
oKiS2C/wShhslFHupkZs+tCEMOsi7tSDt1FlKSIRVvp+rrOwcRapKCHZC8wjYcyh
Ajt/4vVQNMiU6M2E4An4UkeeGgDGWQYdQsc6B9bzqHGESeY1egTLU0LcwSdEYt6G
8KdpBE2wtmhpGZqj55K4hxxiBvp8VS4lqb72k8C0I/TC36JDuB6ntTkAe6+Gsgcu
ZkJCSsLaYPPLo5+sfQ5gnvGcti6NmSimuV88xmG5UnmAsfTumcc/MZGVuJdywmpO
j5M0GnGEWdfAwZbYFAillHS14UdyEC85mCf9wUqrT5EuD1FUzLbRZsQwHXuIGwBZ
YupkMkhv+W97EWEWsJ37XWddSoBZU58TNX4mu0TBVL3lokEpLO0b4ehkd3cQHvk0
eEN9lHbOh1K24wBTmk95RoxFMttP4OL3SSDBvHGh+CwMNsntf3tAs3CbOx4zlhdn
A79Av6lltr+eA4N/uXbORC0Ha4GHygFyoeFmveMZRT5cMnWN9dhPXZ3onQx4+Uj2
+gwqC41NrJmwsAd6MPWozqZgEAWBtB2hQOQiOr9qRfjluUfWddtQyJVZTp6LZmJk
iyV0TLSnXHGRaxKWzxjXDwIDAQABo1AwTjAdBgNVHQ4EFgQU7nCEoRoPDab/U6vc
R9heDwrXZPowHwYDVR0jBBgwFoAU7nCEoRoPDab/U6vcR9heDwrXZPowDAYDVR0T
BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAgEAoK7594/VrR3WpGskG6q+8v5sVr15
hXBEch+Iw2RE/dfGUvt5orJxPnSlEa/4ne2fEKkcV5cEsYqz/7Sl/kq6L8AzRI4C
hh+B9Yqw3nXVB/wlXr9q0i4B4yXUAJ6FHWBM6Ix8kMYhxHOMl0b7Qi8p4cnYhvWC
ESsgsuzShTtLNfFD8jKlOFeBVcv4pQ1tqE/Jki73FOcmMVslqA5gC74+0Xdl0Qp+
hrnt4hODPEQEHcCVepIW3ydcL2TgNXXpg6SuPr4AfEYMCLD+35MLqrAokFj/fign
C6UYv9VdxVQURJ9Fzl6wtIYNlug16v2h3pkcemPMsd/Yn++qNnWes9oV1LQqkFbB
qd+86QQalCgncwZX8sN6zL374m5LWXlk4Y2FMS8e73W0ZxzwXY0Mw+cJ2jiuHOAO
BVbIxDAb75be/7H4mM8xRkyyX2xMBZUtyfQ/Zdv7o6CdnO2iCrLnFOug/GKekOki
SKMmn8kU6swVsr0EvWr6jW//J6/sMvdGx123GS2CDvtylBgX7Dk5Wzv4HB8KuSix
A5bo4WL4FMQwLxYff7rrOBXxhjT16KNtZqXXM39CMaY5Sb454vh3tcGEmiNvPgl5
8GW3jISm5FRohA2ZKL9C1uOiTHut3lPRmzV/F0zTcKlLqoGAuInlZiFYeky6tg//
23VZ2+443gKTc7M=
-----END CERTIFICATE-----
")
