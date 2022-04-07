# frozen_string_literal: true

require 'spec_helper_acceptance'

# Tests pe_status_check class for default behaviours, no notification on all facts passing
# Ensures default PE deployment passes all test cases
describe 'pe_status_check class' do
  context 'activates module default parameters' do
    it 'applies the class with default parameters' do
      pp = <<-MANIFEST
        include pe_status_check
        MANIFEST
      idempotent_apply(pp)
    end
    # Test Confirms all facts are false which is another indicator the class is performing correctly
    describe 'check no pe_status_check fact is false' do
      it 'if idempotent all facts should be true' do
        expect(host_inventory['facter']['pe_status_check'].size).to eq(31)
        expect(host_inventory['facter']['pe_status_check'].filter { |_k, v| !v }).to be_empty
      end
    end

    # Test Confirms nofifications are working as expected, appearing if a fact is set to false, and not triggering
    # if the same fact is placed in the indicator_exclusions parameter
    # This test also serves as confirmation fact S0001 is working Correctly
    describe 'check notifications work as expected' do
      it 'if S0001 reports false notify with message' do
        pp = <<-MANIFEST
        include pe_status_check
        MANIFEST
        run_shell('puppet resource service puppet ensure=stopped')
        result = run_shell('facter -p pe_status_check.S0001')
        output = apply_manifest(pp).stdout
        expect(output).to match('S0001 is at fault. The indicator Determines if Puppet agent Service is running, refer to documentation for required action')
        expect(result.stdout).to match(%r{false})
      end
      it 'if in the exclude list a parameter should not notify' do
        ppp = <<-MANIFEST
        class {'pe_status_check':
            indicator_exclusions => ['S0001'],
            }
        MANIFEST
        idempotent_apply(ppp)
        run_shell('puppet resource service puppet ensure=running')
      end
    end

    # Each facts failing condition should be set and the output of the facts tested
    describe 'check all facts report false in the proper conditions' do
      it 'if S0002 conditions for false are met' do
        run_shell('puppet resource service pxp-agent ensure=stopped')
        result = run_shell('facter -p pe_status_check.S0002')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet resource service pxp-agent ensure=running')
      end
      it 'if S0003 conditions for false are met' do
        run_shell('puppet config set noop true', expect_failures: false)
        result = run_shell('facter -p pe_status_check.S0003')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet config set noop false', expect_failures: false)
      end
      it 'if S0004 conditions for false are met' do
        run_shell('puppet resource service pe-puppetserver  ensure=stopped')
        result = run_shell('facter -p pe_status_check.S0004')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet resource service pe-puppetserver  ensure=running')
      end

      it 'if S0006 conditions for false are met' do
        run_shell('systemctl stop puppet_puppetserver-metrics.timer')
        result = run_shell('facter -p pe_status_check.S0006')
        expect(result.stdout).to match(%r{false})
        run_shell('systemctl start puppet_puppetserver-metrics.timer')
      end

      context 'when filesystem usage exceeds 80%' do
        before(:all) do
          run_shell('fallocate -l $(($(facter -p mountpoints.\'/\'.available_bytes)-1073741824)) /largefile.txt')
        end

        after(:all) do
          run_shell('rm -rf  /largefile.txt')
        end

        it 'sets S0007 to false' do
          result = run_shell('facter -p pe_status_check.S0007')
          expect(result.stdout).to match(%r{false})
        end

        it 'sets S0008 to false' do
          result = run_shell('facter -p pe_status_check.S0008')
          expect(result.stdout).to match(%r{false})
        end
      end

      it 'if S0009 conditions for false are met' do
        run_shell('puppet resource service pe-puppetserver ensure=stopped')
        result = run_shell('facter -p pe_status_check.S0009')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet resource service pe-puppetserver ensure=running')
      end

      it 'if S0010 conditions for false are met' do
        run_shell('puppet resource service pe-puppetdb ensure=stopped')
        result = run_shell('facter -p pe_status_check.S0010')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet resource service pe-puppetdb ensure=running')
      end

      it 'if S0011 conditions for false are met' do
        run_shell('puppet resource service pe-postgresql ensure=stopped')
        result = run_shell('facter -p pe_status_check.S0011')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet resource service pe-postgresql ensure=running')
      end
      it 'if S0012 conditions for false are met' do
        run_shell('puppet config set runinterval 20')
        result = run_shell('facter -p pe_status_check.S0012')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet config set runinterval 1800')
      end
      it 'if S0013 conditions for false are met' do
        run_shell('export lastrunfile=$(puppet config print lastrunfile) && cp $lastrunfile ${lastrunfile}.bk  && sed -i \'/catalog_application/d\' $lastrunfile')
        result = run_shell('facter -p pe_status_check.S0013')
        expect(result.stdout).to match(%r{false})
        run_shell('export lastrunfile=$(puppet config print lastrunfile) && mv -f ${lastrunfile}.bk $lastrunfile')
      end
      it 'if S0014 conditions for false are met' do
        run_shell('touch -d "40 minutes ago" /opt/puppetlabs/server/data/puppetdb/stockpile/cmd/q/acceptance.txt')
        result = run_shell('facter -p pe_status_check.S0014')
        expect(result.stdout).to match(%r{false})
        run_shell('rm -f /opt/puppetlabs/server/data/puppetdb/stockpile/cmd/q/acceptance.txt')
      end
      it 'if S0016 conditions for false are met' do
        run_shell('export logdir=$(puppet config print logdir) &&
         cp $logdir/../puppetserver/puppetserver.log $logdir/../puppetserver/puppetserver.log.bk &&
        echo "java.lang.OutOfMemoryError" >> $logdir/../puppetserver/puppetserver.log')
        result = run_shell('facter -p pe_status_check.S0016')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f $logdir/../puppetserver/puppetserver.log &&
        mv $logdir/../puppetserver/puppetserver.log.bk $logdir/../puppetserver/puppetserver.log')
      end
      it 'if S0016 returns false when recent err_pid files are present' do
        run_shell('export logdir=$(puppet config print logdir) && touch $logdir/../puppetserver/test_err_pid_123.log')
        result = run_shell('facter -p pe_status_check.S0016')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f logdir/../puppetserver/test_err_pid_123.log')
      end
      it 'if S0017 conditions for false are met' do
        run_shell('export logdir=$(puppet config print logdir) && cp $logdir/../puppetdb/puppetdb.log $logdir/../puppetdb/puppetdb.log.bk &&
         echo "java.lang.OutOfMemoryError" >> $logdir/../puppetdb/puppetdb.log')
        result = run_shell('facter -p pe_status_check.S0017')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f $logdir/../puppetdb/puppetdb.log &&
        mv $logdir/../puppetdb/puppetdb.log.bk $logdir/../puppetdb/puppetdb.log')
      end
      it 'if S0017 returns false when recent err_pid files are present' do
        run_shell('export logdir=$(puppet config print logdir) && touch $logdir/../puppetdb/test_err_pid_123.log')
        result = run_shell('facter -p pe_status_check.S0017')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f logdir/../puppetdb/test_err_pid_123.log')
      end
      it 'if S0018 conditions for false are met' do
        run_shell('export logdir=$(puppet config print logdir) &&
         cp $logdir/../orchestration-services/orchestration-services.log $logdir/../orchestration-services/orchestration-services.log.bk &&
         echo "java.lang.OutOfMemoryError" >> $logdir/../orchestration-services/orchestration-services.log')
        result = run_shell('facter -p pe_status_check.S0018')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f $logdir/../orchestration-services/orchestration-services.log &&
        mv $logdir/../orchestration-services/orchestration-services.log.bk $logdir/../orchestration-services/orchestration-services.log')
      end
      it 'if S0018 returns false when recent err_pid files are present' do
        run_shell('export logdir=$(puppet config print logdir) && touch $logdir/../orchestration-services/test_err_pid_123.log')
        result = run_shell('facter -p pe_status_check.S0018')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f logdir/../orchestration-services/test_err_pid_123.log')
      end
      it 'if S0019 returns false when Average Free JRubies is > 0.9' do
        run_shell('puppet agent --enable; puppet agent -t; puppet agent -t; puppet agent -t; puppet agent --disable', expect_failures: true)
        result = run_shell('facter -p pe_status_check.S0019')
        expect(result.stdout).to match(%r{false})
      end
      it 'if S0021 conditions for false are met' do
        run_shell('mkdir -p /etc/puppetlabs/facter/facts.d/;echo \'{
  "memory": {
    "system": {
      "available": "10.32 GiB",
      "available_bytes": 11076337664,
      "capacity": "95.27%",
      "total": "15.46 GiB",
      "total_bytes": 16598274048,
      "used": "5.14 GiB",
      "used_bytes": 5521936384
    }
  }
}\' > /etc/puppetlabs/facter/facts.d/memory.json')
        result = run_shell('facter -p pe_status_check.S0021')
        expect(result.stdout).to match(%r{false})
        run_shell('rm -f /etc/puppetlabs/facter/facts.d/memory.json')
      end
      it 'if S0022 conditions for false are met' do
        run_shell('mv /etc/puppetlabs/license.key /tmp/license.key')
        run_shell('echo -e "#######################\n#  Begin License File #\n#######################\n \n# PUPPET ENTERPRISE LICENSE - test
          \nuuid: test\n \nto: test\n \nnodes: 100\n \nlicense_type: Subscription\n \nsupport_type: PE Premium\n \nstart: 2022-01-01\n \nend: 2022-03-29
          \n#####################\n#  End License File #\n#####################" > /etc/puppetlabs/license.key')
        result = run_shell('facter -p pe_status_check.S0022')
        expect(result.stdout).to match(%r{false})
        run_shell('mv -f /tmp/license.key /etc/puppetlabs/license.key')
      end
      it 'if S0024 conditions for false are met' do
        run_shell('touch -d "30 minutes ago"  /opt/puppetlabs/server/data/puppetdb/stockpile/discard/test.file')
        result = run_shell('facter -p pe_status_check.S0024')
        expect(result.stdout).to match(%r{false})
        run_shell('touch -d "2 days ago"  /opt/puppetlabs/server/data/puppetdb/stockpile/discard/test.file')
      end
      it 'if S0030 conditions for false are met' do
        run_shell('puppet config set use_cached_catalog true', expect_failures: false)
        result = run_shell('facter -p pe_status_check.S0030')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet config set use_cached_catalog false', expect_failures: false)
      end
      it 'if S0031 conditions for false are met' do
        run_shell('mkdir -p /opt/puppetlabs/server/data/packages/public/2018.1.5/el-7-x86_64-5.5.8')
        result = run_shell('facter -p pe_status_check.S0031')
        expect(result.stdout).to match(%r{false})
        run_shell('rm -rf /opt/puppetlabs/server/data/packages/public/2018.1.5')
      end
      it 'if S0039 conditions for false are met' do
        run_shell('export logdir=$(puppet config print logdir) &&
         cp $logdir/../puppetserver/puppetserver-access.log $logdir/../puppetserver/puppetserver-access.log.bk && sed -i \'s/ 200 / 503 /\' /var/log/puppetlabs/puppetserver/puppetserver-access.log')
        # rubocop:enable Layout/LineLength
        result = run_shell('facter -p pe_status_check.S0039')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f $logdir/../puppetserver/puppetserver-access.log &&
        mv $logdir/../puppetserver/puppetserver-access.log.bk $logdir/../puppetserver/puppetserver-access.log')
      end
      it 'if S0033 conditions for false are met' do
        run_shell('cat <<EOF > /etc/puppetlabs/puppet/hiera.yaml
---
:backends:
  - mongodb
  - eyaml
  - yaml
:yaml:
  :datadir: "/etc/puppetlabs/code/environments/%{environment}/hieradata"
:mongodb:
  :connections:
    :dbname: hdata
    :collection: config
    :host: localhost
:eyaml:
  :datadir: "/etc/puppetlabs/code/environments/%{environment}/hieradata"
  :pkcs7_private_key: /etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem
  :pkcs7_public_key:  /etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem
:hierarchy:
  - "nodes/%{trusted.certname}"
  - "location/%{facts.whereami}/%{facts.group}"
  - "groups/%{facts.group}"
  - "os/%{facts.os.family}"
  - "common"
:logger: console
:merge_behavior: native
:deep_merge_options: {}')
        result = run_shell('facter -p pe_status_check.S0033')
        expect(result.stdout).to match(%r{false})
        run_shell('cat << EOF > /etc/puppetlabs/puppet/hiera.yaml
---
# Hiera 5 Global configuration file

version: 5

# defaults:
#   data_hash: yaml_data
# hierarchy:
#  - name: Common
#    data_hash: yaml_data
hierarchy:
- name: Classifier Configuration Data
  data_hash: classifier_data')
      end
      it 'if S0034 conditions for false are met' do
        run_shell('touch -d "2 years ago"  /opt/puppetlabs/server/pe_build')
        result = run_shell('facter -p pe_status_check.S0034')
        expect(result.stdout).to match(%r{false})
        run_shell('touch -d "1 day ago"  /opt/puppetlabs/server/pe_build')
      end
      it 'if S0036 conditions for false are met' do
        present = <<-PUPPETCODE
        pe_hocon_setting { 'jruby-puppet.max-queued-requests':
          ensure  => present,
          path    => '/etc/puppetlabs/puppetserver/conf.d/pe-puppet-server.conf',
          setting => 'jruby-puppet.max-queued-requests',
          value   => 151,
        }
        PUPPETCODE
        absent = <<-PUPPETCODE
        pe_hocon_setting { 'jruby-puppet.max-queued-requests':
          ensure  => absent,
          path    => '/etc/puppetlabs/puppetserver/conf.d/pe-puppet-server.conf',
          setting => 'jruby-puppet.max-queued-requests',
        }
        PUPPETCODE
        apply_manifest(present)
        result = run_shell('facter -p pe_status_check.S0036')
        expect(result.stdout).to match(%r{false})
        apply_manifest(absent)
      end

      it 'if S0038 conditions for false are met' do
        run_shell('for i in $(seq 100); do mkdir /etc/puppetlabs/code/environments/pe_status_check_test_env$i; done')
        result = run_shell('facter -p pe_status_check.S0038')
        expect(result.stdout).to match(%r{false})
        run_shell('rmdir /etc/puppetlabs/code/environments/pe_status_check_test_env*')
      end

      it 'if S0040 conditions for false are met' do
        run_shell('systemctl stop puppet_system_processes-metrics.timer')
        result = run_shell('facter -p pe_status_check.S0040')
        expect(result.stdout).to match(%r{false})
        run_shell('systemctl start puppet_system_processes-metrics.timer')
      end
      it 'if S0042 conditions for false are met' do
        run_shell('systemctl stop pe-orchestration-services')
        result = run_shell('facter -p pe_status_check.S0042')
        expect(result.stdout).to match(%r{false})
        run_shell('systemctl start pe-orchestration-services')
      end
    end
  end
end
