kubectl create serviceaccount openclaw-bot -n openclaw
kubectl apply -f role.yaml
kubectl create clusterrolebinding openclaw-read-binding \
  --clusterrole=openclaw-read \
  --serviceaccount=openclaw:openclaw-bot
kubectl create token openclaw-bot -n openclaw
