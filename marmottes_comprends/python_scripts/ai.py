from openai import OpenAI
import json
client = OpenAI(
    base_url="https://marmottesjourney.myphone.education/v1",
    api_key="1debf3b82095e69c9ee98d348b164973b1b8812cd34d9ca255fb8eaf94465e9f7ac08822f8bef1f1dd3db9793b1ac870180e5af552972efd6592915634e920f3",
)

completion = client.chat.completions.create(
  model="codestral",
  messages=[
    {"role": "user", "content": """#Goal:
You are an expert at structured data extraction. You will be given unstructured text from a Cyber Patriot ReadMe and should convert it into the given structure. This data must include the title (name of the image), all users (all authorized users), new users (any additional users the document asks to create), critical services, and a markdown summary. For each user, you **must** mention the groups they're appart of, the account name, and permissions they sould have (admin or not). The data should be in JSON format. You may only output JSON and nothing else! Your response should be in the format of the JSON Schema

#JSON Schema:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "structured_readme",
  "type": "object",
  "properties": {
    "title": {
      "type": "string"
    },
    "all_users": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "name": {
            "type": "string"
          },
          "account_type": {
            "type": "string",
            "enum": ["admin", "standard"]
          },
          "groups": {
            "type": "array",
            "items": {
              "type": "string"
            }
          }
        },
        "required": ["name", "groups", "account_type"],
        "additionalProperties": false
      }
    },
    "new_users": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "name": {
            "type": "string"
          },
          "account_type": {
            "type": "string",
            "enum": ["admin", "standard"]
          },
          "groups": {
            "type": "array",
            "items": {
              "type": "string"
            }
          },
          "password": {
            "type": "string"
          }
        },
        "required": ["name", "groups", "account_type", "password"],
        "additionalProperties": false
      }
    },
    "critical_services": {
      "type": "array",
      "items": {
        "type": "string"
      }
    },
    "markdown_summary": {
      "type": "string"
    }
  },
  "required": ["title", "all_users", "new_users", "critical_services", "markdown_summary"],
  "additionalProperties": false
}

#Readme:
```
CyberPatriot Training Round Windows 10 README

Please read the entire README thoroughly before modifying anything on this computer.
Unique Identifier

If you have not yet entered a valid Unique Identifier, please do so immediately by double clicking on the "CyberPatriot Set Unique Identifier" icon on the desktop. If you do not enter a valid Unique Identifier this VM may stop functioning after a short period of time.
Forensics Questions

If there are "Forensics Questions" on your Desktop, you will receive points for answering these questions correctly. Valid (scored) "Forensics Questions" will only be located directly on your Desktop. Please read all "Forensics Questions" thoroughly before modifying this computer, as you may change something that prevents you from answering the question correctly.
Competition Scenario

You work for a new board game development company.

This company's security policies require that all user accounts be password protected. Employees are required to choose secure passwords, however this policy may not be currently enforced on this computer. The presence of any non-work related media files and "hacking tools" on any computers is strictly prohibited. This company currently does not use any centralized maintenance or polling tools to manage their IT equipment. This computer is for official business use only by authorized users. Your job is to secure this computer, within the guidelines of the scenario, while ensuring the availability of authorized business critical software and services.

Company policy states that Windows Action Center should be enabled and monitoring the security status of desktop Windows operating systems at all times.

This is a critical computer in a production environment. Please do NOT attempt to install Windows "Feature Updates" or "Insider Preview Builds." Please do NOT attempt to use the Windows recovery options "Reset this PC" or "Go back to an earlier build".
Windows 10 LTSC 2019

It is company policy to use only Windows 10 on this computer. Management has decided that the default web browser for all users on this computer should be the latest stable version of Firefox. Employees should also have access to the latest stable version of GIMP and Inkscape for company use. Any required software should not be installed using the Microsoft store.

Your company just hired a new employee. Make a new account for this employee named "alexei".

Some users have just been placed into a new working group by management. Make a new group called "hypersonic" and add the following users to the "hypersonic" group: ntrace, mgarcia, bcoleman, alexei.

This is a standalone workstation machine and does not have any business critical services.

Critical Services:

    (None)

Authorized Administrators and Users

Authorized Administrators:
eleven (you)
	password: niNApr0je(t
pmitchell
	password: p4Lac|In11
tkazansky
	password: w@teRG/\t3
ccain
	password: ne\/er3ND5try
bsimpson
	password: inn3r5tRE|\|gth

Authorized Users:
abenjamin
bbradshaw
rfloyd
sbates
bcoleman
cbradshaw
ntrace
rfitch
mgarcia
jmachado
bavalone
llee
blennox
nvikander
cbassett
skazansky

Competition Guidelines

    In order to provide a better competition experience, you are NOT required to change the password of the primary, auto-login, user account. Changing the password of a user that is set to automatically log in may lock you out of your computer.
    Authorized administrator passwords were correct the last time you did a password audit, but are not guaranteed to be currently accurate.
    Do not stop or disable the CCS Client service or process.
    Do not remove any authorized users or their home directories.
    The time zone of this image is set to UTC. Please do not change the time zone, date, or time on this image.
    You can view your current scoring report by double-clicking the "CyberPatriot Scoring Report" desktop icon.
    JavaScript is required for some error messages that appear on the "CyberPatriot Scoring Report." To ensure that you only receive correct error messages, please do not disable JavaScript.
    Some security settings may prevent the Stop Scoring application from running. If this happens, the safest way to stop scoring is to suspend the virtual machine. You should NOT power on the VM again before deleting.

ANSWER KEY

    This is an introductory image with an answer key available here.


        The CyberPatriot Competition System is the property of the Air and Space Forces Association and the University of Texas at San Antonio.

        All rights reserved.
```"""}
  ]
)

print(json.dumps(json.loads(completion.choices[0].message.content), indent=4))