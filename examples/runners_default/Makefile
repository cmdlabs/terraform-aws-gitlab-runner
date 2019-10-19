.PHONY: plan
plan:
	TF_VAR_enable_gitlab_runner_ssh_access=false terraform plan -out tf.plan ; \
		terraform show -json tf.plan | jq . > plan.json ; \
		rm -f tf.plan
