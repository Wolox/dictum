require 'spec_helper'

describe 'Dictum::Documenter' do
  subject(:documenter) { Dictum::Documenter.instance }
  let(:resource) { 'Tests' }
  let(:resource_description) { 'Description' }

  before(:each) do
    subject.reset_resources
  end

  describe '#resource' do
    let(:arguments) { { name: resource, description: resource_description } }

    it 'adds the resource internally' do
      expect { subject.resource(arguments) }
        .to change { subject.resources }
        .from({})
        .to(resource.to_s => { description: resource_description, endpoints: [] })
    end

    it 'writes the result in the temp directory' do
      File.delete(subject.tempfile_path) if File.exist?(subject.tempfile_path)
      subject.resource(arguments)
      expect(File.exist?(subject.tempfile_path)).to be_truthy
    end

    it 'writes the contents of the tempfile correctly' do
      subject.resource(arguments)
      expect(File.open(subject.tempfile_path, 'r').read).to eq(JSON.generate(subject.resources))
    end

    context 'when arguments are empty' do
      let(:resource) { nil }

      it 'does not add anything' do
        expect { subject.resource }.not_to change { subject.resources }
      end

      it 'does not add anything with nil' do
        expect { subject.resource(nil) }.not_to change { subject.resources }
      end

      it 'does not add anything without name' do
        expect { subject.resource({}) }.not_to change { subject.resources }
      end

      it 'does not add anything with no name' do
        expect { subject.resource(arguments) }.not_to change { subject.resources }
      end
    end
  end

  describe '#endpoint' do
    let(:endpoint) { '/api/tests' }
    let(:http_verb) { 'POST' }
    let(:endpoint_description) { 'Description' }
    let(:request_headers) { { 'X-TEST' => 'test' } }
    let(:request_path_parameters) { { id: 1 } }
    let(:request_body_parameters) { { email: 'test' } }
    let(:response_status) { 200 }
    let(:response_headers) { { 'SOME_HEADER' => 'test' } }
    let(:response_body) { { test: request_path_parameters.merge(request_body_parameters) } }
    let(:arguments) do
      { resource: resource, endpoint: endpoint, http_verb: http_verb, response_body: response_body,
        request_headers: request_headers, request_path_parameters: request_path_parameters,
        request_body_parameters: request_body_parameters, response_status: response_status,
        response_headers: response_headers, description: endpoint_description }
    end

    context 'when the resource has already been added' do
      before(:each) do
        subject.reset_resources
        subject.resource(name: resource, description: resource_description)
      end

      it 'adds the correct resources internally' do
        subject.endpoint(arguments)
        expect(subject.resources).to eq(
          resource.to_s => {
            description: resource_description,
            endpoints: [
              { endpoint: endpoint,
                description: endpoint_description,
                http_verb: http_verb,
                request_headers: request_headers,
                request_path_parameters: request_path_parameters,
                request_body_parameters: request_body_parameters,
                response_status: response_status,
                response_headers: response_headers,
                response_body: response_body }
            ]
          }
        )
      end

      context 'when there are some nil arguments' do
        let(:http_verb) { nil }
        let(:endpoint_description) { nil }
        let(:request_headers) { nil }
        let(:request_path_parameters) { nil }
        let(:request_body_parameters) { nil }
        let(:response_status) { nil }
        let(:response_headers) { nil }
        let(:response_body) { nil }

        it 'adds the empty resources internally' do
          subject.endpoint(arguments)
          expect(subject.resources).to eq(
            resource.to_s => {
              description: resource_description,
              endpoints: [
                { endpoint: endpoint,
                  description: endpoint_description,
                  http_verb: '',
                  request_headers: nil,
                  request_path_parameters: nil,
                  request_body_parameters: nil,
                  response_status: nil,
                  response_headers: nil,
                  response_body: nil }
              ]
            }
          )
        end
      end
    end

    context 'when the resource was not added before' do
      it 'adds the resource internally' do
        subject.endpoint(arguments)
        expect(subject.resources[resource].nil?).to be_falsey
      end

      it 'adds the correct resources internally' do
        expect { subject.endpoint(arguments) }
          .to change { subject.resources }
          .from({})
          .to(
            resource.to_s => {
              endpoints: [
                { endpoint: endpoint,
                  description: endpoint_description,
                  http_verb: http_verb,
                  request_headers: request_headers,
                  request_path_parameters: request_path_parameters,
                  request_body_parameters: request_body_parameters,
                  response_status: response_status,
                  response_headers: response_headers,
                  response_body: response_body }
              ]
            }
          )
      end
    end

    it 'writes the result in the temp directory' do
      File.delete(subject.tempfile_path) if File.exist?(subject.tempfile_path)
      subject.endpoint(arguments)
      expect(File.exist?(subject.tempfile_path)).to be_truthy
    end

    it 'writes the contents of the tempfile correctly' do
      subject.endpoint(arguments)
      expect(File.open(subject.tempfile_path, 'r').read).to eq(JSON.generate(subject.resources))
    end

    context 'when not sending the mandatory parameters' do
      it 'does not add anything without endpoint' do
        arguments[:endpoint] = nil
        expect { subject.endpoint(arguments) }.not_to change { subject.resources }
      end

      it 'does not add anything without resource' do
        arguments[:resource] = nil
        expect { subject.endpoint(arguments) }.not_to change { subject.resources }
      end
    end
  end
end
