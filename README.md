# hello-devops — مشروع عملي يمرّ على مراحل DevOps الثمانية

تطبيق Node.js صغير جدًا (بدون أي مكتبات) فيه 3 مسارات: `/` رسالة ترحيب، `/health` فحص الصحة، `/metrics` عدّاد طلبات لـ Prometheus.

## المتطلبات (مجانية)
Git + حساب GitHub، Node.js 20+، Docker Desktop، kubectl، kind (أو تفعيل Kubernetes في Docker Desktop)، Terraform، Ansible (على Linux أو WSL).

## هيكل المشروع
| المجلد / الملف | المرحلة |
|---|---|
| `app/` + `package.json` | البرمجة والاختبار |
| `.github/workflows/ci.yml` | البناء + الاختبار + الإصدار (GitHub Actions) |
| `Dockerfile` | التغليف (Docker) |
| `k8s/` | النشر (Kubernetes) |
| `terraform/` | تجهيز البنية (Terraform) |
| `ansible/` | تهيئة الخادم (Ansible) |
| `monitoring/` + `docker-compose.monitoring.yml` | المراقبة (Prometheus + Grafana) |

## 1) التخطيط (Plan)
المستودع موجود عندك: `AlaaBashirSaijary/Devops`، ثم افتح Issue بعنوان «إضافة مسار /health» وضع له Label. هذه هي مهمتك الأولى.

## 2) البرمجة (Code)
```bash
git init && git add . && git commit -m "feat: initial app"
git branch -M main
git remote add origin https://github.com/AlaaBashirSaijary/Devops.git
git checkout -b feature/health      # فرع للمهمة
# ... عدّل الكود ...
git push -u origin feature/health   # ثم افتح Pull Request
```
جرّب التطبيق محليًا: `npm start` ثم افتح http://localhost:3000

## 3) الاختبار (Test)
```bash
npm test
```
عند فتح الـ Pull Request يشغّل GitHub Actions نفس الاختبار تلقائيًا (job اسمه `test`). اكسر الاختبار عمدًا لترى الفشل، ثم أصلحه.

## 4) البناء والإصدار (Build + Release)
عند دمج الـ PR في `main` يبني الـ Workflow صورة Docker ويدفعها إلى `ghcr.io/alaabashirsaijary/devops` بوسمين: رقم الـ commit و`latest`.
- بعد أول دفع: من GitHub ← Packages ← الصورة ← Package settings ← اجعلها **Public** كي تسحبها Kubernetes بدون أسرار.
- محليًا للتجربة: `docker build -t hello-devops . && docker run -p 3000:3000 hello-devops`

## 5) تجهيز البنية (Terraform)
ننشئ Namespace داخل Cluster محلي (مجاني، بدون سحابة):
```bash
kind create cluster          # أو فعّل Kubernetes في Docker Desktop
cd terraform
terraform init
terraform plan
terraform apply
```

## 6) النشر (Kubernetes)
(الصورة مضبوطة مسبقًا على حسابك) ثم:
```bash
kubectl apply -f k8s/
kubectl get pods -n hello-devops
kubectl port-forward -n hello-devops svc/hello 8080:80
# افتح http://localhost:8080
```
جرّب الشفاء الذاتي: `kubectl delete pod <اسم-pod> -n hello-devops` وشاهد إنشاء بديل فورًا.
جرّب التراجع: `kubectl rollout undo deployment/hello -n hello-devops`

## 7) التشغيل وتهيئة الخادم (Ansible)
على خادم Ubuntu (أو WSL) يثبّت Docker ويشغّل التطبيق كحاوية:
```bash
ansible-galaxy collection install community.docker
cd ansible
ansible-playbook -i inventory.ini playbook.yml --ask-become-pass
```
أعد التشغيل مرة ثانية وستجد `changed=0` (خاصية Idempotency). لخادم بعيد غيّر `inventory.ini` إلى `IP ansible_user=ubuntu`.

## 8) المراقبة (Monitor)
شغّل التطبيق على المنفذ 3000 ثم:
```bash
docker compose -f docker-compose.monitoring.yml up -d
```
- Prometheus: http://localhost:9090 — جرّب الاستعلام `http_requests_total`
- Grafana: http://localhost:3001 (admin / admin) ← أضف Data source من نوع Prometheus بالعنوان `http://prometheus:9090`
- أوقف التطبيق وانتظر دقيقة لترى التنبيه `AppDown` في تبويب Alerts.

## الدورة تتكرر
ما تراه في المراقبة يتحول إلى Issue جديد في التخطيط، وهكذا تكتمل حلقة DevOps.
