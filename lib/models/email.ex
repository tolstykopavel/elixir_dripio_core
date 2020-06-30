defmodule Dripio.Email do
  import Bamboo.Email
  require Bamboo.MandrillHelper
  use Dripio.Trace

  def user_registration(user, link) do
    Trace.wrap do
      vars = [
        %{
          name: "fname",
          content: user.fname
        },
        %{
          name: "lname",
          content: user.lname
        },
        %{
          name: "email",
          content: user.email
        },
        %{
          name: "link",
          content: link
        }
      ]

      new_email()
      |> to(user.email)
      |> from("support@dripio.com")
      |> bcc("des.binc@gmail.com")
      |> Bamboo.MandrillHelper.put_param("merge_language", "handlebars")
      |> Bamboo.MandrillHelper.put_param("merge_vars", [
        %{
          rcpt: "des.binc@gmail.com",
          vars: vars
        },
        %{
          rcpt: user.email,
          vars: vars
        }
      ])
      |> Bamboo.MandrillHelper.template("verify-your-email-to-complete-dripio-account-setup")
    end
  end

  def email_confirmation(user, link) do
    Trace.wrap do
      vars = [
        %{
          name: "fname",
          content: user.fname
        },
        %{
          name: "lname",
          content: user.lname
        },
        %{
          name: "email",
          content: user.email
        },
        %{
          name: "link",
          content: link
        }
      ]

      new_email()
      |> to(user.email)
      |> from("support@dripio.com")
      |> bcc("des.binc@gmail.com")
      |> Bamboo.MandrillHelper.put_param("merge_language", "handlebars")
      |> Bamboo.MandrillHelper.put_param("merge_vars", [
        %{
          rcpt: "des.binc@gmail.com",
          vars: vars
        },
        %{
          rcpt: user.email,
          vars: vars
        }
      ])
      |> Bamboo.MandrillHelper.template("verify-your-email-to-complete-dripio-account-setup")
    end
  end

  def reset_password(user, link) do
    Trace.wrap do
      vars = [
        %{
          name: "fname",
          content: user.fname
        },
        %{
          name: "lname",
          content: user.lname
        },
        %{
          name: "email",
          content: user.email
        },
        %{
          name: "link",
          content: link
        }
      ]

      new_email()
      |> to(user.email)
      |> from("support@dripio.com")
      |> bcc("des.binc@gmail.com")
      |> Bamboo.MandrillHelper.put_param("merge_language", "handlebars")
      |> Bamboo.MandrillHelper.put_param("merge_vars", [
        %{
          rcpt: "des.binc@gmail.com",
          vars: vars
        },
        %{
          rcpt: user.email,
          vars: vars
        }
      ])
      |> Bamboo.MandrillHelper.template("finishing-your-dripio-password-reset")
    end
  end

  def device_status_change(device) do
    Trace.wrap do
      vars = [
        %{
          name: "status",
          content:
            case device.status do
              true -> "online"
              _ -> "offline"
            end
        },
        %{
          name: "nick",
          content: device.title
        },
        %{
          name: "serial",
          content: device.id
        }
      ]

      new_email()
      |> to("alerts@dripio.com")
      |> from("alerts@dripio.com")
      |> bcc("des.binc@gmail.com")
      |> Bamboo.MandrillHelper.put_param("merge_language", "handlebars")
      |> Bamboo.MandrillHelper.put_param("merge_vars", [
        %{
          rcpt: "des.binc@gmail.com",
          vars: vars
        },
        %{
          rcpt: "alerts@dripio.com",
          vars: vars
        }
      ])
      |> Bamboo.MandrillHelper.template("controller-status-change")
    end
  end

  def contact_email(form) do
    Trace.wrap do
      vars = [
        %{
          "name" => "username",
          "content" => form.username
        },
        %{
          "name" => "email",
          "content" => form.liame
        },
        %{
          "name" => "subject",
          "content" => form.subject
        },
        %{
          "name" => "message",
          "content" => form.message
        }
      ]

      new_email()
      |> to("support@dripio.com")
      |> from("info@dripio.com")
      |> bcc("des.binc@gmail.com")
      |> Bamboo.MandrillHelper.put_param("merge_language", "handlebars")
      |> Bamboo.MandrillHelper.put_param("merge_vars", [
        %{
          rcpt: "des.binc@gmail.com",
          vars: vars
        },
        %{
          rcpt: "support@dripio.com",
          vars: vars
        }
      ])
      |> Bamboo.MandrillHelper.template("contact-email")
    end
  end
end
