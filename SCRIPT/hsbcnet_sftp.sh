output_file=${1}
title=${2}
printer_name=${3}
sftp_userid=${4}
sftp_server=${5}
sftp_port=${6}
time=`date +%Y%m%d%H%M%S`
req_id=`echo "${title}" | rev | cut -d"." -f1 | rev`

# for debuging
rm /var/tmp/hsbcnet_sftp_dev.log
touch hsbcnet_sftp_dev.log
echo "Script Start Time : ${time}" >> /var/tmp/hsbcnet_sftp_dev.log
echo "1) ${output_file}"  >> /var/tmp/hsbcnet_sftp_dev.log
echo "2) ${title}"        >> /var/tmp/hsbcnet_sftp_dev.log
echo "3) ${printer_name}" >> /var/tmp/hsbcnet_sftp_dev.log
echo "4) ${req_id}" >> /var/tmp/hsbcnet_sftp_dev.log
echo "5) ${sftp_userid}" >> /var/tmp/hsbcnet_sftp_dev.log
echo "6) ${sftp_server}" >> /var/tmp/hsbcnet_sftp_dev.log
echo "7) ${sftp_port}" >> /var/tmp/hsbcnet_sftp_dev.log
echo "cd $APPLCSF/out" >> /var/tmp/hsbcnet_sftp_dev.log
cd $APPLCSF/out
echo "ls -l hsbc*${req_id}.xml" >> /var/tmp/hsbcnet_sftp_dev.log
ls -l XXIBY_PAYMENT_TRANSFER*${req_id}*.XML >> /var/tmp/hsbcnet_sftp_dev.log
#sftp -P 10022 PC000019209_20324@ecom-sftp.fguk-pprd.hsbc.com
echo "Start : sftp -P ${sftp_port} ${sftp_userid}@${sftp_server}" >> /var/tmp/hsbcnet_sftp_dev.log
echo "Will  put XXIBY_PAYMENT_TRANSFER*${req_id}*.XML file to HSBC SFTP Server." >> /var/tmp/hsbcnet_sftp_dev.log
#sftp -P ${sftp_port} ${sftp_userid}@${sftp_server} <<EOF
#put XXIBY_PAYMENT_TRANSFER*${req_id}*.XML
#bye
#EOF
echo "End   : sftp -P ${sftp_port} ${sftp_userid}@${sftp_server}" >> /var/tmp/hsbcnet_sftp_dev.log
