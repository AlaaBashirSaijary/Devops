# مختبر عملي: جرّب كل أداة بنفسك (بدون تثبيت شيء على جهازك)

يعمل المختبر داخل **GitHub Codespaces**: جهاز Linux في المتصفح فيه Docker وkubectl وkind وTerraform وAnsible جاهزة. لا يستهلك مساحة من لابتوبك.

**التشغيل:** من صفحة المستودع اضغط `Code` ← `Codespaces` ← `Create codespace on main`. انتظر دقائق حتى ينتهي الإعداد، ثم افتح الـ Terminal وانسخ الأوامر بالترتيب. (الحساب المجاني يمنح ساعات شهرية؛ احذف الـ Codespace عند الانتهاء.)

## بديل مجاني إن انتهى رصيد Codespaces
مواقع مختبرات مجانية في المتصفح (تسجيل دخول بحساب GitHub أو Google، والجلسة مؤقتة نحو ساعة):
- **Killercoda — Ubuntu:** https://killercoda.com/playgrounds/scenario/ubuntu ← لأقسام Docker وAnsible وPrometheus.
- **Killercoda — Kubernetes:** https://killercoda.com/playgrounds/scenario/kubernetes ← لأقسام Terraform وKubernetes (الـ cluster جاهز، فتجاوز أمر `kind create cluster`).

في كل جهاز نفّذ أولًا:
```bash
curl -fsSL https://raw.githubusercontent.com/AlaaBashirSaijary/Devops/main/lab-setup.sh | bash
cd Devops
```
ثم تابع الأقسام أدناه. إن كان جهازًا بلا Docker (Kubernetes) فخطوات Docker وAnsible وPrometheus نفّذها في جهاز Ubuntu.

## 1) Docker — صورة وحاويات
```bash
docker build -t hello-devops .          # يبني الصورة من Dockerfile
docker images hello-devops              # الصورة = القالب
docker run -d --name app1 -p 3000:3000 hello-devops   # حاوية 1
docker run -d --name app2 -p 3001:3000 hello-devops   # حاوية 2 من الصورة نفسها
docker ps                               # حاويتان من صورة واحدة
curl localhost:3000/api/info ; curl localhost:3001/api/info
docker rm -f app1 app2
```

## 2) Kubernetes — cluster محلي داخل Docker
```bash
kind create cluster
kubectl get nodes
```

## 3) Terraform — ينشئ الـ namespace
```bash
cd terraform && terraform init && terraform plan && terraform apply -auto-approve && cd ..
kubectl get namespace hello-devops      # أنشأه Terraform
terraform -chdir=terraform plan         # لا تغييرات: الواقع = الكود
```

## 4) Kubernetes — النشر والشفاء الذاتي
```bash
kubectl apply -f k8s/
kubectl -n hello-devops get pods                       # 3 نسخ
kubectl -n hello-devops delete pod $(kubectl -n hello-devops get pod -o name | head -1)
kubectl -n hello-devops get pods                       # ظهر بديل فورًا
kubectl -n hello-devops scale deployment/hello --replicas=5
kubectl -n hello-devops rollout undo deployment/hello  # تراجع
kubectl -n hello-devops port-forward svc/hello 8080:80 &
curl localhost:8080/api/info            # لاحظ تغيّر اسم الـ Pod بين الطلبات
```

## 5) Ansible — تهيئة خادم (مرتان)
```bash
cd ansible
~/.local/bin/ansible-playbook -i inventory.ini playbook.yml -e install_docker=false
~/.local/bin/ansible-playbook -i inventory.ini playbook.yml -e install_docker=false   # changed=0
cd ..
```

## 6) Prometheus — مراقبة وتنبيه
```bash
sed 's#host.docker.internal:3000#localhost:3000#' monitoring/prometheus.yml > /tmp/prometheus.yml
cp monitoring/alerts.yml /tmp/alerts.yml
docker run -d --name prom --network host -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml -v /tmp/alerts.yml:/etc/prometheus/alerts.yml prom/prometheus
```
افتح المنفذ 9090 من تبويب Ports واكتب `http_requests_total`. أوقف الحاوية `docker stop hello` وانتظر دقيقة لترى التنبيه `AppDown` في تبويب Alerts.

## التنظيف
```bash
kind delete cluster ; docker rm -f prom hello 2>/dev/null
```
ثم احذف الـ Codespace من github.com/codespaces.
