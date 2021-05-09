import 'package:flutter/material.dart';


class TermsAndCondition extends StatelessWidget {
  static const routeName = '/terms';
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return  Scaffold(
      body: SafeArea(
        child: Container(
          width: width,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.04),
                      child: Center(
                          child: Text(
                            'Terms',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: width*0.078,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.04, left: 10),
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            'Consumer fraud alert:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: width,
                      child: Text(
                        'Never share your password with anyone. Immediately notify the MiPay Inc team in the event your account gets compromised, password gets stolen, or if someone used your account without your permission. ',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          'MiPay services are aided by Paystack.',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            'General Provisions: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                              'By signing up for using our services, on iOS and Android applications, you agree to our terms and conditions which are as follows:'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '1.Definition:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '- When we say “you”, “Sender”, “User”, and  “Customer” we referring to the users who have registered us MiPay services.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '- When we say withdrawal, top-up, we a referring to transfer of funds to designated beneficiaries.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '2. Confidentiality and Privacy:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '-  Your personal information will be treated and processed securely and strictly in accordance with applicable laws and regulations. ',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '-  We may disclose customer information if we are required to do so by law, by court order, by any statutory, legal or regulatory requirement, by the police or any other competent authorities in connection with the prevention or detection of crime or to help combat fraud, money laundering and terrorism financing. We may also report suspicious activity to appropriate competent law enforcement or government authorities.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '3. Disputes:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '- If you have any problems using our mobile services or need to dispute a transaction, please email us at mipay@outlook.com.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '4. Eligibility and your access rights:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '-  By using the Service you warrant that you are at least 18 years old and that you have a legal capacity to enter into legally binding contracts.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                              '-  We reserve the right, at any time, to terminate or suspend your access to the Service without prior notice if (but not limited to):'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            " * You use the Service or attempt to use it for any Prohibited Purpose;\n * You attempt to transfer or charge funds from an account that does not belong to you;\n * We receive conflicting claims regarding ownership of or the right to withdraw funds from a debit or credit card account;\n" +
                                " * You have provided us with false evidence of your identity or you keep failing in providing us with true, accurate, current and complete evidence of your identity or details regarding transactions;\n" +
                                " * You attempt to tamper, hack, modify, overload, or otherwise corrupt or circumvent the security and/or functionality of the Application or to infect it with any Malicious Code;\n" +
                                "* You are in breach of these Terms and Conditions;\n",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '5. What you need to know about our services:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            ' - To help the government fight the funding of terrorism and money laundering activities, we will obtain, verify, and record certain information about you when you create a MiPay account.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            ' -   To create an account, we will ask for your email, mobile number and other information that will enable us to identify you. We may also ask to see your driver\'s license or other identifying documents',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                              '- We charge a service fee at the point of each withdrawal you make.'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '6. Information we provide after a Top-up and Withdrawals transaction is complete:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                              'We provide you with the  amount, time and date of your top-up while we also provide with the account name in addition to former provisions for  withdrawals.'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '7. Fees and Charges:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            'We charge an amount of 0.01 Kobo for each card you add in to the application in other to verify your card and also we charge a service fee on your withdrawals depending on amount you want to withdraw.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '8. Reliance by MiPay Inc:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            'You represent and warrant that all information that you enter regarding the Remittance is true and complete. When processing a Remittance, MiPay Inc may rely on the registration information and any other information that you provide. You acknowledge that any errors in the information, including misidentification of the Beneficiary, incorrect or inconsistent account names and numbers, or misspellings, are your responsibility and that MiPay Inc shall have no liability for executing a Remittance based upon the inaccurate or incomplete information you provided or entered.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '9. Intellectual Property:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            'This Site, including all text, graphics, logos and image, as well as all other MiPay Inc copyrights, trademarks, service marks, products and service names are the exclusive property of MiPay Inc  and Paystack, therefore, may not be used for any purpose without express written permission from MiPay Inc.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '10. Compliance:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            'MiPay Inc has zero tolerance for any criminal, fraudulent, money laundering, and the funding of terrorist activities. We will report anyone suspected of financial crimes to the appropriate Nigerian authorities.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '11. Error Resolution Time frames:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            'In Case of Errors or Questions About Your Electronic Transfers: Contact us by sending a support message via the email stated above if you think your statement or receipt is wrong or if you need more information about a transfer on the statement or receipt. We must hear from you no later than sixty (60) days after we sent you the FIRST statement on which the error or problem appeared.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            'Your inquiry must include: Your name and account number; AND a description of the error or the transfer you are unsure about, and a clear explanation of why you believe there is an error or why you need more information.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '12. Funds Transfer Limit:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            'Daily transfer limit can be increased to no more than 5,000,000 Naira per day.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            '13. Disclaimer of warranties:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            'THE SERVICE IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS WITHOUT ANY REPRESENTATION OF WARRANTY. MiPay EXPRESSLY DISCLAIM ALL WARRANTIES WHETHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
