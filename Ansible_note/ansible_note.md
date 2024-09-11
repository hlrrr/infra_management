

- changed ssh port
  ```
  .ini file
  
  [node ip] ansible_port=10022
  ```
  
- install community module
  ```
  ansible-galaxy collection install community.docker
  ```
  
- become sudo auth
  ```
  become: yes
  become_method: sudo
  become_user: root
  ```
  
- Remote host auth/permission problem
  ```
	/etc/ansible/ansible.cfg

	[privilege_escalation]
	become=True
	become_method=sudo
	become_user=root
	become_ask_pass=True
  ```
