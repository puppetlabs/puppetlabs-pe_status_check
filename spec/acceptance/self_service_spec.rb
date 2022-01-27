# frozen_string_literal: true

require 'spec_helper_acceptance'

# Tests Self_service class for default behaviours, no notification on all facts passing
# Ensures default PE deployment passes all test cases
describe 'self_service class' do
  context 'activates module default parameters' do
    it 'applies the class with default parameters' do
      pp = <<-MANIFEST
        include self_service
        MANIFEST
      idempotent_apply(pp)
    end
    # Test Confirms all facts are false which is another indicator the class is performing correctly
    describe 'check no self_service fact is false' do
      it 'if idempotent all facts should be true' do
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
        expect(host_inventory['facter']['self_service'].size).to eq(26)
=======
        expect(host_inventory['facter']['self_service'].size).to eq(15)
>>>>>>> (SUP-2939) Remove High Load Average test
=======
        expect(host_inventory['facter']['self_service'].size).to eq(16)
>>>>>>> (SUP-2912) added a check to see if Global hiera is Hiera 5
=======
        expect(host_inventory['facter']['self_service'].size).to eq(17)
>>>>>>> (SUP-2919) - is puppet_metrics_collector::system configured
=======
        expect(host_inventory['facter']['self_service'].size).to eq(19)
>>>>>>> (SUP-2901) License check, tests and readme update
        expect(host_inventory['facter']['self_service'].filter { |_k, v| !v }).to be_empty
      end
    end

    # Test Confirms nofifications are working as expected, appearing if a fact is set to false, and not triggering
    # if the same fact is placed in the indicator_exclusions parameter
    # This test also serves as confirmation fact S0001 is working Correctly
    describe 'check notifications work as expected' do
      it 'if S0001 reports false notify with message' do
        pp = <<-MANIFEST
        include self_service
        MANIFEST
        run_shell('puppet resource service puppet ensure=stopped')
        result = run_shell('facter -p self_service.S0001')
        output = apply_manifest(pp).stdout
        expect(output).to match('Notice: S0001 is at fault, please refer to documentation for required action')
        expect(result.stdout).to match(%r{false})
      end
      it 'if in the exclude list a parameter should not notify' do
        ppp = <<-MANIFEST
        class {'self_service':
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
        result = run_shell('facter -p self_service.S0002')
        expect(result.stdout).to match(%r{false})
      end
      it 'if S0003 conditions for false are met' do
        run_shell('puppet config set noop true', expect_failures: false)
        result = run_shell('facter -p self_service.S0003')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet config set noop false', expect_failures: false)
      end
      it 'if S0004 conditions for false are met' do
        run_shell('puppet resource service pe-orchestration-services  ensure=stopped')
        result = run_shell('facter -p self_service.S0004')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet resource service pe-orchestration-services  ensure=running')
      end

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> (SUP-2946) Check Metrics Collector is enabled
      it 'if S0006 conditions for false are met' do
        run_shell('puppet agent --disable')
        run_shell('systemctl stop puppet_puppetserver-metrics.timer')
        result = run_shell('facter -p self_service.S0006')
        expect(result.stdout).to match(%r{false})
        run_shell('systemctl start puppet_puppetserver-metrics.timer')
        run_shell('puppet agent --enable')
      end

<<<<<<< HEAD
=======
>>>>>>> (SUP-2939) Remove High Load Average test
=======
>>>>>>> (SUP-2946) Check Metrics Collector is enabled
      context 'when filesystem usage exceeds 80%' do
        before(:all) do
          run_shell('fallocate -l $(($(facter -p mountpoints.\'/\'.available_bytes)-1073741824)) /largefile.txt')
        end

        after(:all) do
          run_shell('rm -rf  /largefile.txt')
        end

        it 'sets S0007 to false' do
          result = run_shell('facter -p self_service.S0007')
          expect(result.stdout).to match(%r{false})
        end

        it 'sets S0008 to false' do
          result = run_shell('facter -p self_service.S0008')
          expect(result.stdout).to match(%r{false})
        end
      end

      it 'if S0009 conditions for false are met' do
        run_shell('puppet resource service pe-puppetserver ensure=stopped')
        result = run_shell('facter -p self_service.S0009')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet resource service pe-puppetserver ensure=running')
      end

      it 'if S0010 conditions for false are met' do
        run_shell('puppet resource service pe-puppetdb ensure=stopped')
        result = run_shell('facter -p self_service.S0010')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet resource service pe-puppetdb ensure=running')
      end

      it 'if S0011 conditions for false are met' do
        run_shell('puppet resource service pe-postgresql ensure=stopped')
        result = run_shell('facter -p self_service.S0011')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet resource service pe-postgresql ensure=running')
      end
      it 'if S0012 conditions for false are met' do
        run_shell('puppet agent --disable; puppet config set runinterval 20')
        result = run_shell('facter -p self_service.S0012')
        expect(result.stdout).to match(%r{false})
        run_shell(' puppet config set runinterval 1800;puppet agent --enable')
      end
      it 'if S0013 conditions for false are met' do
        run_shell('export lastrunfile=$(puppet config print lastrunfile) && cp $lastrunfile ${lastrunfile}.bk  && sed -i \'/catalog_application/d\' $lastrunfile')
        result = run_shell('facter -p self_service.S0013')
        expect(result.stdout).to match(%r{false})
        run_shell('export lastrunfile=$(puppet config print lastrunfile) && mv -f ${lastrunfile}.bk $lastrunfile')
      end
      it 'if S0014 conditions for false are met' do
        run_shell('touch -d "40 minutes ago" /opt/puppetlabs/server/data/puppetdb/stockpile/cmd/q/acceptance.txt')
        result = run_shell('facter -p self_service.S0014')
        expect(result.stdout).to match(%r{false})
        run_shell('rm -f /opt/puppetlabs/server/data/puppetdb/stockpile/cmd/q/acceptance.txt')
      end
      it 'if S0016 conditions for false are met' do
        run_shell('export logdir=$(puppet config print logdir) &&
         cp $logdir/../puppetserver/puppetserver.log $logdir/../puppetserver/puppetserver.log.bk &&
        echo "java.lang.OutOfMemoryError" >> $logdir/../puppetserver/puppetserver.log')
        result = run_shell('facter -p self_service.S0016')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f $logdir/../puppetserver/puppetserver.log &&
        mv $logdir/../puppetserver/puppetserver.log.bk $logdir/../puppetserver/puppetserver.log')
      end
      it 'if S0016 returns false when recent err_pid files are present' do
        run_shell('export logdir=$(puppet config print logdir) && touch $logdir/../puppetserver/test_err_pid_123.log')
        result = run_shell('facter -p self_service.S0016')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f logdir/../puppetserver/test_err_pid_123.log')
      end
      it 'if S0017 conditions for false are met' do
        run_shell('export logdir=$(puppet config print logdir) && cp $logdir/../puppetdb/puppetdb.log $logdir/../puppetdb/puppetdb.log.bk &&
         echo "java.lang.OutOfMemoryError" >> $logdir/../puppetdb/puppetdb.log')
        result = run_shell('facter -p self_service.S0017')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f $logdir/../puppetdb/puppetdb.log &&
        mv $logdir/../puppetdb/puppetdb.log.bk $logdir/../puppetdb/puppetdb.log')
      end
      it 'if S0017 returns false when recent err_pid files are present' do
        run_shell('export logdir=$(puppet config print logdir) && touch $logdir/../puppetdb/test_err_pid_123.log')
        result = run_shell('facter -p self_service.S0017')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f logdir/../puppetdb/test_err_pid_123.log')
      end
      it 'if S0018 conditions for false are met' do
        run_shell('export logdir=$(puppet config print logdir) &&
         cp $logdir/../orchestration-services/orchestration-services.log $logdir/../orchestration-services/orchestration-services.log.bk &&
         echo "java.lang.OutOfMemoryError" >> $logdir/../orchestration-services/orchestration-services.log')
        result = run_shell('facter -p self_service.S0018')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f $logdir/../orchestration-services/orchestration-services.log &&
        mv $logdir/../orchestration-services/orchestration-services.log.bk $logdir/../orchestration-services/orchestration-services.log')
      end
      it 'if S0018 returns false when recent err_pid files are present' do
        run_shell('export logdir=$(puppet config print logdir) && touch $logdir/../orchestration-services/test_err_pid_123.log')
        result = run_shell('facter -p self_service.S0018')
        expect(result.stdout).to match(%r{false})
        run_shell('export logdir=$(puppet config print logdir) && rm -f logdir/../orchestration-services/test_err_pid_123.log')
      end
      it 'if S0019 returns false when Average Free JRubies is > 0.9' do
        run_shell('puppet agent -t && puppet agent -t && puppet agent -t', expect_failures: true)
        result = run_shell('facter -p self_service.S0019')
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
        result = run_shell('facter -p self_service.S0021')
        expect(result.stdout).to match(%r{false})
        run_shell('rm -f /etc/puppetlabs/facter/facts.d/memory.json')
      end
      it 'if S0022 conditions for false are met' do
        run_shell('mv /etc/puppetlabs/license.key /tmp/license.key')
        result = run_shell('facter -p self_service.S0022')
<<<<<<< HEAD
=======
        expect(result.stdout).to match(%r{false})
        run_shell('mv /tmp/license.key /etc/puppetlabs/license.key')
      end
      it 'if S0036 conditions for false are met' do
        run_shell('echo "puppet_enterprise::master::puppetserver::jruby_puppet_max_queued_requests: 151" >> /etc/puppetlabs/code/environments/production/data/common.yaml')
        run_shell('puppet resource service puppet ensure=stopped')
        run_shell('puppet agent -t', expect_failures: true)
        result = run_shell('facter -p self_service.S0036')
>>>>>>> (SUP-2901) License check, tests and readme update
        expect(result.stdout).to match(%r{false})
        run_shell('mv /tmp/license.key /etc/puppetlabs/license.key')
      end
      it 'if S0030 conditions for false are met' do
        run_shell('puppet config set use_cached_catalog true', expect_failures: false)
        result = run_shell('facter -p self_service.S0030')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet config set use_cached_catalog false', expect_failures: false)
      end
<<<<<<< HEAD
      it 'if S0031 conditions for false are met' do
        run_shell('mkdir -p /opt/puppetlabs/server/data/packages/public/2018.1.5/el-7-x86_64-5.5.8')
        result = run_shell('facter -p self_service.S0031')
        expect(result.stdout).to match(%r{false})
        run_shell('rm -rf /opt/puppetlabs/server/data/packages/public/2018.1.5')
      end
=======
>>>>>>> (SUP-2912) added a check to see if Global hiera is Hiera 5
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
        result = run_shell('facter -p self_service.S0033')
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
<<<<<<< HEAD
<<<<<<< HEAD
      it 'if S0034 conditions for false are met' do
        run_shell('touch -d "2 years ago"  /opt/puppetlabs/server/pe_build')
        result = run_shell('facter -p self_service.S0034')
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
        result = run_shell('facter -p self_service.S0036')
        expect(result.stdout).to match(%r{false})
        apply_manifest(absent)
      end
=======
>>>>>>> (SUP-2919) - is puppet_metrics_collector::system configured
      it 'if S0040 conditions for false are met' do
        run_shell('puppet agent --disable')
        run_shell('systemctl stop puppet_system_processes-metrics.timer')
        result = run_shell('facter -p self_service.S0040')
        expect(result.stdout).to match(%r{false})
        run_shell('systemctl start puppet_system_processes-metrics.timer')
        run_shell('puppet agent --enable')
      end
<<<<<<< HEAD
=======
>>>>>>> (SUP-2912) added a check to see if Global hiera is Hiera 5
=======
>>>>>>> (SUP-2919) - is puppet_metrics_collector::system configured
    end
  end
end
