#!/bin/bash

HOSTIP=9.20.201.69

openssl req -x509 -nodes -sha256 -subj "/CN=demo-ingress.${HOSTIP}.nip.io" -days 3650 -newkey rsa:2048 -keyout test.key -out test.crt

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
type: kubernetes.io/tls
metadata:
  name: test-secret
data:
  tls.crt: $(cat test.crt | base64 | tr -d '\n')
  tls.key: $(cat test.key | base64 | tr -d '\n')
EOF

cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: demo-ingress
spec:
  rules:
  - host: demo-ingress.${HOSTIP}.nip.io
    http:
      paths:
      - backend:
          serviceName: nginx
          servicePort: 80
  tls:
  - hosts:
    - demo-ingress.${HOSTIP}.nip.io
    secretName: test-secret
EOF

kubectl apply -f manifests