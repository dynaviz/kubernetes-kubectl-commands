# kubectx and kubens - Kubernetes Context and Namespace Management Tools

## Overview

**kubectx** and **kubens** are command-line utilities that simplify switching between Kubernetes contexts and namespaces. They are part of the same project and provide a faster, more user-friendly alternative to verbose `kubectl` commands.

### What Problem Do They Solve?

**Without these tools:**
```bash
# Switching contexts (clusters)
kubectl config use-context production-cluster

# Checking current context
kubectl config current-context

# Switching namespaces
kubectl config set-context --current --namespace=my-namespace

# Checking current namespace
kubectl config view --minify --output 'jsonpath={..namespace}'
```

**With kubectx and kubens:**
```bash
# Switching contexts
kubectx production-cluster

# Switching namespaces
kubens my-namespace
```

Much simpler and faster!

---

## kubectx - Context Switcher

### Purpose
- Quickly switch between Kubernetes clusters (contexts)
- View available contexts at a glance
- Remember and switch back to previous context
- Essential for engineers managing multiple Kubernetes clusters

### Common Use Cases
- **Multi-cluster management**: Development, staging, production
- **Multi-cloud setups**: AWS EKS, Azure AKS, GCP GKE
- **Client work**: Switching between different customer clusters
- **Local vs. remote**: Minikube, kind, Docker Desktop vs. cloud clusters

### Usage Examples

```bash
# List all available contexts
kubectx

# Switch to a specific context
kubectx minikube

# Switch to production
kubectx production-cluster

# Switch back to previous context
kubectx -

# Show current context
kubectx -c

# Rename a context (for easier identification)
kubectx new-name=old-name

# Delete a context
kubectx -d context-name
```

---

## kubens - Namespace Switcher

### Purpose
- Quickly switch between Kubernetes namespaces within a context
- View all namespaces in current cluster
- Avoid typing `--namespace` or `-n` flag repeatedly
- Remember and switch back to previous namespace

### Common Use Cases
- **Environment isolation**: dev, test, staging namespaces
- **Multi-tenancy**: Different teams or projects in same cluster
- **Application segregation**: Frontend, backend, databases
- **Debugging**: Quickly switch between namespaces to investigate issues

### Usage Examples

```bash
# List all namespaces in current context
kubens

# Switch to a specific namespace
kubens kube-system

# Switch to default namespace
kubens default

# Switch back to previous namespace
kubens -

# Show current namespace
kubens -c
```

---

## Installation Methods

### Method 1: Direct Download (Recommended for Quick Setup)

**Install kubectx:**
```bash
sudo curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o /usr/local/bin/kubectx
sudo chmod +x /usr/local/bin/kubectx
```

**Install kubens:**
```bash
sudo curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o /usr/local/bin/kubens
sudo chmod +x /usr/local/bin/kubens
```

**Verify installation:**
```bash
kubectx --help
kubens --help
```

---

### Method 2: Clone Repository (Includes Completion Scripts)

**Clone and symlink:**
```bash
# Clone the repository
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx

# Create symbolic links
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install bash completion (optional)
sudo cp /opt/kubectx/completion/kubectx.bash /etc/bash_completion.d/kubectx
sudo cp /opt/kubectx/completion/kubens.bash /etc/bash_completion.d/kubens

# For zsh completion
mkdir -p ~/.oh-my-zsh/completions
ln -s /opt/kubectx/completion/_kubectx.zsh ~/.oh-my-zsh/completions/_kubectx
ln -s /opt/kubectx/completion/_kubens.zsh ~/.oh-my-zsh/completions/_kubens
```

---

### Method 3: Using Homebrew (Linux/macOS)

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install kubectx (includes kubens)
brew install kubectx
```

---

### Method 4: Using kubectl krew Plugin Manager

```bash
# Install krew if not already installed
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# Add krew to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Install plugins
kubectl krew install ctx
kubectl krew install ns

# Usage
kubectl ctx    # same as kubectx
kubectl ns     # same as kubens
```

---

## Practical Workflow Examples

### Example 1: Multi-Environment Development

```bash
# Morning: Start work on development cluster
kubectx dev-cluster
kubens my-app-dev

# Deploy and test
kubectl apply -f deployment.yaml
kubectl get pods

# Switch to staging for testing
kubectx staging-cluster
kubens my-app-staging

# Deploy to staging
kubectl apply -f deployment.yaml

# Quick check on production
kubectx production-cluster
kubens my-app-prod
kubectl get pods

# Go back to dev
kubectx dev-cluster
kubens my-app-dev
```

### Example 2: Debugging Across Namespaces

```bash
# Check application in default namespace
kubens default
kubectl get pods

# Check database in database namespace
kubens database
kubectl logs mongodb-0

# Check monitoring tools
kubens monitoring
kubectl get svc

# Go back to application namespace
kubens -
```

### Example 3: Managing Multiple Cloud Providers

```bash
# List all clusters
kubectx

# Output might show:
# aws-eks-production
# azure-aks-staging
# gcp-gke-dev
# minikube

# Switch between clouds
kubectx aws-eks-production
kubectx azure-aks-staging
kubectx minikube
```

---

## Advanced Tips

### 1. Interactive Selection with fzf

Install `fzf` for fuzzy finding:
```bash
sudo apt install fzf
```

Now you can:
- Run `kubectx` and select from an interactive list
- Run `kubens` and select from an interactive list
- Type to search/filter contexts or namespaces

### 2. Create Aliases

Add to your `~/.bashrc` or `~/.zshrc`:
```bash
# Shorter aliases
alias kctx='kubectx'
alias kns='kubens'

# Quick shortcuts to common contexts
alias dev='kubectx dev-cluster'
alias staging='kubectx staging-cluster'
alias prod='kubectx production-cluster'

# Quick namespace shortcuts
alias ns-default='kubens default'
alias ns-system='kubens kube-system'
alias ns-monitoring='kubens monitoring'
```

### 3. Color Output

Enable colored output for better visibility:
```bash
# Add to ~/.bashrc or ~/.zshrc
export KUBECTX_CURRENT_FGCOLOR=$(tput setaf 2)  # green
export KUBECTX_CURRENT_BGCOLOR=$(tput setab 0)  # black background
```

### 4. Context and Namespace in Shell Prompt

Show current context and namespace in your prompt:

**For bash (~/.bashrc):**
```bash
kube_ps1() {
    local ctx=$(kubectx -c 2>/dev/null)
    local ns=$(kubens -c 2>/dev/null)
    if [ -n "$ctx" ]; then
        echo "☸️ ($ctx:$ns)"
    fi
}
PS1='$(kube_ps1) \u@\h:\w\$ '
```

**For zsh with oh-my-zsh:**
```bash
# Install kube-ps1 plugin
git clone https://github.com/jonmosco/kube-ps1.git ~/.oh-my-zsh/custom/plugins/kube-ps1

# Add to ~/.zshrc
plugins=(... kube-ps1)

# Update prompt
PROMPT='$(kube_ps1)'$PROMPT
```

---

## Comparison with kubectl Commands

| Task | kubectl Command | kubectx/kubens |
|------|----------------|----------------|
| List contexts | `kubectl config get-contexts` | `kubectx` |
| Switch context | `kubectl config use-context name` | `kubectx name` |
| Current context | `kubectl config current-context` | `kubectx -c` |
| List namespaces | `kubectl get namespaces` | `kubens` |
| Switch namespace | `kubectl config set-context --current --namespace=name` | `kubens name` |
| Previous context | Manual tracking required | `kubectx -` |
| Previous namespace | Manual tracking required | `kubens -` |

---

## Common Issues and Troubleshooting

### Issue 1: "kubectx: command not found"

**Solution:**
```bash
# Check if installed
which kubectx

# If not found, reinstall
sudo curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o /usr/local/bin/kubectx
sudo chmod +x /usr/local/bin/kubectx

# Verify PATH includes /usr/local/bin
echo $PATH
```

### Issue 2: "kubens shows no namespaces"

**Solution:**
```bash
# Verify kubectl works
kubectl get namespaces

# Check current context
kubectx -c

# Verify kubeconfig
kubectl config view
```

### Issue 3: Permission denied

**Solution:**
```bash
# Fix permissions
sudo chmod +x /usr/local/bin/kubectx
sudo chmod +x /usr/local/bin/kubens
```

### Issue 4: Context exists but not switching

**Solution:**
```bash
# Check kubeconfig syntax
kubectl config view

# Manually verify context
kubectl config use-context context-name

# If working manually, kubectx should work too
kubectx context-name
```

---

## Best Practices

1. **Use descriptive context names**: Rename contexts for clarity
   ```bash
   kubectx production=arn:aws:eks:us-east-1:123456789012:cluster/prod
   ```

2. **Always verify before destructive operations**: Check context and namespace before running destructive commands
   ```bash
   kubectx -c && kubens -c
   kubectl delete pod important-pod
   ```

3. **Set default namespace for new contexts**: 
   ```bash
   kubectx new-context
   kubens default
   ```

4. **Use with other tools**: Combine with k9s, stern, or other Kubernetes tools
   ```bash
   kubectx staging-cluster
   kubens my-app
   k9s  # Opens k9s in current context/namespace
   ```

5. **Document your contexts**: Keep a reference of what each context represents
   ```bash
   # Example: contexts.txt
   minikube          - Local development
   dev-cluster       - Development environment (AWS)
   staging-aks       - Staging environment (Azure)
   prod-gke          - Production cluster (GCP)
   ```

---

## Integration with Other Tools

### k9s (Kubernetes CLI UI)
```bash
kubectx production
kubens app-namespace
k9s  # Opens in the selected context/namespace
```

### stern (Multi-pod log tailing)
```bash
kubens backend
stern api-server  # Tails logs from all api-server pods in backend namespace
```

### helm
```bash
kubectx prod-cluster
kubens my-app
helm list  # Shows releases in current namespace
helm install my-release ./chart
```

### kubectl plugins
```bash
kubens monitoring
kubectl top pods  # Shows resource usage in monitoring namespace
```

---

## Security Considerations

1. **Be extra careful with production contexts**: 
   - Use clear naming conventions
   - Always verify before executing commands
   - Consider using read-only contexts when possible

2. **Protect your kubeconfig file**:
   ```bash
   chmod 600 ~/.kube/config
   ```

3. **Use namespace isolation**: 
   - Different namespaces for different environments
   - Use RBAC to limit access per namespace

4. **Audit context switches**: 
   - Keep logs of context changes in sensitive environments
   - Use admission controllers for production

---

## Additional Resources

- **Official Repository**: https://github.com/ahmetb/kubectx
- **Kubernetes Documentation**: https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
- **fzf Integration**: https://github.com/junegunn/fzf
- **kube-ps1 Prompt**: https://github.com/jonmosco/kube-ps1

---

## Summary

**kubectx** and **kubens** are essential productivity tools for anyone working with Kubernetes, especially when:
- Managing multiple clusters
- Working across different environments (dev, staging, prod)
- Switching between namespaces frequently
- Need to improve workflow efficiency

They reduce context-switching friction and minimize typing errors, making Kubernetes operations faster and safer.

**Quick Start:**
```bash
# Install both tools
sudo curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o /usr/local/bin/kubectx && \
sudo curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o /usr/local/bin/kubens && \
sudo chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens

# Start using
kubectx              # List contexts
kubectx minikube     # Switch to minikube
kubens               # List namespaces
kubens default       # Switch to default namespace
```

Happy Kubernetes cluster hopping! 🚀
