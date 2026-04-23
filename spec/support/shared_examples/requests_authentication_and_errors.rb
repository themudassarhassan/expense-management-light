# frozen_string_literal: true

# For request specs. Each `shared_examples` name documents the `let` / block the host must supply.
#
# Id that should not exist in the test database (for missing-record / 404 → root flows).
IMPOSSIBLE_RECORD_ID = 9_999_999_999

# Host: `let(:unauthenticated_request) { proc { get … } }`
RSpec.shared_examples 'a request that requires sign-in' do
  it 'redirects to sign-in when not authenticated' do
    unauthenticated_request.call
    expect(response).to redirect_to(new_session_path)
  end
end

# Host: `let(:missing_record_edit_path)`; use with a signed-in user.
RSpec.shared_examples 'a request to edit a missing record' do
  it 'redirects to root' do
    get missing_record_edit_path
    expect(response).to redirect_to(root_path)
  end
end

# Host: `let(:new_path) { new_*_path }`
RSpec.shared_examples 'a successful GET for a new form' do
  it 'returns success' do
    get new_path
    expect(response).to have_http_status(:ok)
  end
end
