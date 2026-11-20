# Pinning Framework during an EC2 benchmark

Set `METASPLOIT_FRAMEWORK_REVISION` to the full 40-character Framework Git commit
SHA when invoking the normal Omnibus build. This takes precedence over a local
Framework directory and the `master` default. The package's `build_framework_rev`
metadata records that same SHA. An invalid value fails before the build starts.
Leaving the variable unset preserves the current source selection and metadata.

This is input selection only. The companion Jenkins benchmark change selects
fresh ephemeral EC2 workers, disables external publishing and records timings and
costs. This change does not start a benchmark, alter an AMI/instance type, change
compiler settings, publish packages or promote any production defaults.
