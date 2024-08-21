{ pkgs, lib, ...}:
{
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgBVB966ZfrwwOloWlOHeBqIbVFpDxj+bIerQy0TgKNpOZbG8qXaP6zkwyCvY0B8Zqjrvj8sDtcKZkX5YG1qfsunmdnCBvZG3oXWjYzaptpJPnhDQz3yWbShCwzlQ0n/YvkpU5zegYpfYUw5dCvI1FV+OCnjsWqrRTX32XGSsvGTPgfFUYOUZz9V5Qn2gh9/eqPCK4eNM9+gJyk+9izXJLHv3Ksyaeul4O2XHrtiDrZ5BifrENjePKP1cqAqQWX5RNZk+LXLUU1QllSodtMqyH0jA3xJndLTKCx2Rx33XzqNNlmIi/h002CXZJciwR+BJGhmw2nTGoRQ3Q7FIbvBkh marek.faj@gmail.com"
  ];

  services.sshd.enable = true;
}
