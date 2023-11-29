import React, { Component } from 'react'
import SignUpFormContainer from '../../ui/signupform/SignUpFormContainer'

class SignUp extends Component {
  render() {
    return(
      <main className="container">
        <div className="pure-g">
          <div className="pure-u-1-1">
            <h1>Sign Up</h1>
            <p>input your name and your account is generated with a random address for your wallet!</p>
            <h3> SmartRider</h3>
            <SignUpFormContainer />
          </div>
        </div>
      </main>
    )
  }
}

export default SignUp
