require 'support/coverage'
require 'dictum'

CONFIG = {
  output_format: :markdown,
  output_path: "#{Dir.tmpdir}/docs",
  root_path: Dir.tmpdir,
  test_suite: :rspec,
  output_filename: 'Documentation',
  index_title: 'Index',
  header_title: 'Dictum'
}

# Create the test.json file
def create_test_json
  documenter = Dictum::Documenter.instance

  resource_1 = 'Test1'
  resource_2 = 'Test2'
  test_string = 'test'
  test_hash = { test_string => test_string }

  documenter.resource(name: resource_1, description: test_string)
  documenter.resource(name: resource_2, description: test_string)

  documenter.endpoint(resource: resource_1, endpoint: 'api/test1', description: test_string,
                      http_verb: 'GET', request_headers: test_hash,
                      request_path_parameters: test_hash, request_body_parameters: test_hash,
                      response_status: 200, response_headers: test_hash, response_body: test_hash)
  documenter.endpoint(resource: resource_1, endpoint: 'api/test1', description: test_string,
                      http_verb: 'POST', request_headers: test_hash,
                      request_path_parameters: test_hash, request_body_parameters: test_hash,
                      response_status: 200, response_headers: test_hash, response_body: test_hash)

  documenter.endpoint(resource: resource_2, endpoint: 'api/test1', description: test_string,
                      http_verb: 'GET', request_headers: test_hash,
                      request_path_parameters: test_hash, request_body_parameters: test_hash,
                      response_status: 200, response_headers: test_hash, response_body: test_hash)
  documenter.endpoint(resource: resource_2, endpoint: 'api/test1', description: test_string,
                      http_verb: 'GET', request_headers: test_hash,
                      request_path_parameters: test_hash, request_body_parameters: test_hash,
                      response_status: 200, response_headers: test_hash, response_body: test_hash)

  FileUtils.copy(documenter.tempfile_path, './spec/temp')
end

Dir.mkdir('./spec/temp') unless Dir.exist?('./spec/temp')
create_test_json
